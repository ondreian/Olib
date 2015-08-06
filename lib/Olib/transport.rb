module Olib

  class Transport

    @@silvers    = 0
    @@teleporter = {}
    @@routines   = {}

    def Transport.__extend__
      singleton = (class << self; self end)
      [
        'bank', 'gemshop', 'pawnshop', 'advguild', 'forge', 'inn', 'npchealer',
        'chronomage', 'town', 'furrier', 'herbalist', 'locksmith', 'alchemist',
        'fletcher', 'sunfist', 'movers', 'consignment', 'advguard','advguard2',
        'clericshop', 'warriorguild'
      ].each do |target|
        singleton.send :define_method, "go2_#{target}".to_sym do

          unhide if hidden?
          unless Room.current.tags.include?(target)
            start_script 'go2', [target, '_disable_confirm_']
            wait_while { running? "go2" };
          end
          return self
        end
      end
    end

    Transport.__extend__

    def Transport.rebase
      @@origin            = {}
      @@origin[:roomid]   = Room.current.id
      @@origin[:hidden]   = hiding?
      @@origin[:location] = Room.current.location
      self
    end

    Transport.rebase


    # Thanks Tillmen
    def Transport.cost(to)
      cost = 0
      Map.findpath(Room.current.id, to).each { |id|
        Room[id].tags.each { |tag|          
          if tag =~ /^silver-cost:#{id-1}:(.*)$/
            cost_string = $1
            if cost_string =~ /^[0-9]+$/
              cost += cost_string.to_i
            else
              cost = StringProc.new(cost_string).call.to_i
            end
          end
        }
      }
      cost
    end

    # use the teleporter variable to locate your teleporter and teleport
    # naive of where you are
    def Transport.fwi_teleport
      unless Vars.teleporter
        echo "Error: No teleport defined ;var set teleporter=<teleporter>"
        exit
      end
      
      unless Inventory.teleporter
        echo "Error: Your teleporter could not be found #{Vars.teleporter}"
        exit
      end

      last = Room.current.id
      teleporter = Inventory.teleporter
      if teleporter.worn?
        teleporter.turn
      else
        teleporter.take.turn.stash
      end

      if Room.current.id == last
        echo "Error: You tried to teleport to FWI in a room that does not allow that"
      end

      self
    end

    def Transport.wealth
      fput "info"
      while(line=get)
        next                if line =~ /^\s*Name\:|^\s*Gender\:|^\s*Normal \(Bonus\)|^\s*Strength \(STR\)\:|^\s*Constitution \(CON\)\:|^\s*Dexterity \(DEX\)\:|^\s*Agility \(AGI\)\:|^\s*Discipline \(DIS\)\:|^\s*Aura \(AUR\)\:|^\s*Logic \(LOG\)\:|^\s*Intuition \(INT\)\:|^\s*Wisdom \(WIS\)\:|^\s*Influence \(INF\)\:/
        if line =~ /^\s*Mana\:\s+\-?[0-9]+\s+Silver\:\s+([0-9]+)/
          @@silvers= $1.to_i
          break
        end
        sleep 0.1
      end
      @@silvers
    end

    def Transport.deplete(silvers)
      @@silvers = @@silvers - silvers
    end

    def Transport.smart_wealth
      return @@silvers if @@silvers 
      @@wealth
    end

    def Transport.unhide
      fput 'unhide' if Spell[916].active? or hidden?
      self
    end

    def Transport.withdraw(amount)
      go2_bank
      result = Olib.do "withdraw #{amount} silvers", /I'm sorry|hands you/
      if result =~ /I'm sorry/ 
        go2_origin
        echo "Unable to withdraw the amount requested for this script to run from your bank account"
        exit
      end
      return self
    end

    def Transport.deposit_all
      self.go2_bank
      fput "unhide" if invisible? || hidden?
      fput "deposit all"
      return self
    end

    def Transport.deposit(amt)
      self.go2_bank
      fput "unhide" if invisible? || hidden?
      fput "deposit #{amt}"
      return self
    end

    # naive share
    # does not check if you're actually in a group or not
    def Transport.share
      wealth
      fput "share #{@silvers}"
      self
    end

    def Transport.go2(roomid)
      unhide if hidden
      unless Room.current.id == roomid
        start_script 'go2', [roomid, '_disable_confirm_']
        wait_while { running? "go2" };
      end
      return self
    end

    # TODO
    # create a dictionary of house lockers and the logic to enter a locker
    # insure locker is closed before scripting away from it
    def Transport.go2_locker
      echo "the go2_locker method currently does not function properly..."
      self
    end

    def Transport.go2_origin
      if Room.current.id != @@origin[:roomid]
        start_script 'go2', [@origin[:roomid]]
        wait_while { running? "go2" };
      end
      hide if @@origin[:hidden]
      return self
    end    

  end

  def Olib.Transport
    Olib::Transport
  end
end