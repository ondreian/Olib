class Char
  @@silvers  = 0
  @@routines = {}

  def Char.hide
    while not hiding?
      waitrt?
      if @@routines[:hiding]
        @@routines[:hiding].call
      else
        fput 'hide'
      end
    end
    Char
  end

  def Char.fwi_teleporter
    Vars.teleporter || Vars.mapdb_fwi_trinket
  end

  def Char.visible?
    hiding? || invisible?
  end
  
  def Char.hiding_routine(procedure)
    @@routines[:hiding] = procedure
    Char
  end

  def Char.left
    GameObj.left_hand.name == "Empty" ? nil : Olib::Item.new(GameObj.left_hand)
  end

  def Char.right
    GameObj.right_hand.name == "Empty" ? nil : Olib::Item.new(GameObj.right_hand)
  end

  def Char.withdraw(amount)
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

  def Char.deposit_all
    Go2.bank
    fput "unhide" if invisible? || hidden?
    fput "deposit all"
    @@silvers = 0
    return self
  end

  def Char.deposit(amt)
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
  def Char.share
    wealth
    fput "share #{@silvers}"
    wealth
    self
  end

  def Char.deplete_wealth(silvers)
    #@@silvers = @@silvers - silvers
  end

  def Char.smart_wealth
    return @@silvers if @@silvers 
    Char.wealth
  end

  def Char.unhide
    fput 'unhide' if Spell[916].active? or hidden?
    self
  end

  def Char.hide
    if Spell[916].known? && Spell[916].affordable?
      Spell[916].cast
    else
      fput "hide" until hidden?
    end
  end

  def Char.wealth
    fput "info"
    while(line=get)
      next    if line =~ /^\s*Name\:|^\s*Gender\:|^\s*Normal \(Bonus\)|^\s*Strength \(STR\)\:|^\s*Constitution \(CON\)\:|^\s*Dexterity \(DEX\)\:|^\s*Agility \(AGI\)\:|^\s*Discipline \(DIS\)\:|^\s*Aura \(AUR\)\:|^\s*Logic \(LOG\)\:|^\s*Intuition \(INT\)\:|^\s*Wisdom \(WIS\)\:|^\s*Influence \(INF\)\:/
      if line =~ /^\s*Mana\:\s+\-?[0-9]+\s+Silver\:\s+([0-9]+)/
        @@silvers= $1.to_i
        break
      end
      sleep 0.1
    end
    @@silvers
  end
end
