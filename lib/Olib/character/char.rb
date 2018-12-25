class Char
  INJURIES = Wounds.singleton_methods.map(&:to_s).select do |m| m.downcase == m and not m.include?("_") end.map(&:to_sym)
  Duration   = Struct.new(:seconds, :minutes, :hours)
  @@silvers  = 0
  @@aiming   = nil

  def Char.spell(num)
    hour, minutes, seconds = Spell[num].remaining.split(":").map(&:to_f)
    total_seconds = seconds + (minutes * 60.00) + (hour * 60.00 * 60.00)

    Duration.new(
      total_seconds,
      total_seconds/60,
      total_seconds/60/60,
    )
  end

  def self.hide()
    return unless visible?
    fput "hide"
    waitrt?
    self
  end

  def self.unhide()
    return if visible?
    fput "unhide"
    wait_until do visible? end
    self
  end

  def self.arm
    fput "gird"
    self
  end

  def self.unarm
    fput "store both"
    self
  end

  def self.swap
    fput "swap"
    self
  end

  def self.stand
    unless standing?
      fput "stand"
      waitrt?
    end
    self
  end

  def self.aim(location)
    unless @@aiming == location
      fput "aim #{location}"
      @@aiming = location
    end
    self
  end


  def self.visible?
    hiding? or invisible?
  end

  def self.in_town?
    Room.current.location =~ /the Adventurer's Guild|kharam|teras|landing|sol|icemule trace|mist|vaalor|illistim|rest|cysaegir|logoth/i
  end

  def self.left
    GameObj.left_hand.name == "Empty" ? nil : Item.new(GameObj.left_hand)
  end

  def self.right
    GameObj.right_hand.name == "Empty" ? nil : Item.new(GameObj.right_hand)
  end

  def self.withdraw(amount)
    Go2.bank
    result = Olib.do "withdraw #{amount} silvers", /I'm sorry|hands you/
    if result =~ /I'm sorry/ 
      Go2.origin
      echo "Unable to withdraw the amount requested for this script to run from your bank account"
      exit
    end
    wealth
    return self
  end

  def self.deposit_all
    Go2.bank
    fput "unhide" unless visible?
    fput "deposit all"
    @@silvers = 0
    return self
  end

  def self.deposit(amt)
    wealth
    if wealth >= amt
      Go2.bank
      fput "unhide" if invisible? || hidden?
      fput "deposit #{amt}"
    end
    return self
  end

  # naive share
  # does not check if you're actually in a group or not
  def self.share
    wealth
    fput "share #{@silvers}"
    wealth
    self
  end

  def self.deplete_wealth(silvers)
    #@@silvers = @@silvers - silvers
  end

  def self.smart_wealth
    return @@silvers if @@silvers 
    Char.wealth
  end

  def self.unhide
    fput 'unhide' if Spell[916].active? or hidden?
    self
  end

  def self.hide
    if Spell[916].known? && Spell[916].affordable?
      Spell[916].cast
    else
      fput "hide" until hidden?
    end
  end

  def self.wealth
    silvers = nil
    DownstreamHook.add("Olib_check_silvers", Proc.new do |server_string|
      if server_string =~ /^\s*Name\:|^\s*Gender\:|^\s*Normal \(Bonus\)|^\s*Strength \(STR\)\:|^\s*Constitution \(CON\)\:|^\s*Dexterity \(DEX\)\:|^\s*Agility \(AGI\)\:|^\s*Discipline \(DIS\)\:|^\s*Aura \(AUR\)\:|^\s*Logic \(LOG\)\:|^\s*Intuition \(INT\)\:|^\s*Wisdom \(WIS\)\:|^\s*Influence \(INF\)\:/
        nil
      elsif server_string =~ /^\s*Mana\:\s+\-?[0-9]+\s+Silver\:\s+([0-9]+)/
        silvers = $1.to_i
        DownstreamHook.remove("Olib_check_silvers")
        nil
      else
        server_string
      end
    end)
    $_SERVER_.puts "#{$cmd_prefix}info\n"
    wait_until { silvers }
    silvers
    @@silvers = silvers
    @@silvers
  end

  def self.total_wound_severity
    INJURIES
      .reduce(0) do |sum, method| sum + Wounds.send(method) end
  end

  def self.wounded?
    total_wound_severity.gt(0)
  end

  def self.empty_hands
    hands = [Char.left, Char.right].compact

    hands.each do |hand| Containers.Lootsack.add hand end

    yield

    hands.each(&:take)
  end
end
