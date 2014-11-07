module Olib

  class Transport

    attr_accessor :origin, :silvers, :teleporter

    def initialize
      rebase
      @teleporter        = {}
      self.__constructor__
      return self
    end

    def rebase
      @origin            = {}
      @origin[:roomid]   = Room.current.id
      @origin[:hidden]   = hiding?
      @origin[:location] = Room.current.location
      self
    end

    # Thanks Tillmen
    def cost(to)
      cost = 0
      Map.findpath(Room.current.id, @to).each { |id|
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
    def fwi_teleport
      unless @teleporter[:item]
        setting           = 'teleporter'
        if UserVars.send(setting).nil? or UserVars.send(setting).empty?
          echo "error: #{setting.to_s} is not set. (;vars set #{setting.to_s}=<teleporter>)" 
        else
          #echo "locating teleporter..."
          GameObj.containers.map do |container, contents| 
            contents.each do |item|
              if item.full_name =~ /#{UserVars.send(setting)}/
                respond @item
                @teleporter[:container] = container
                @teleporter[:item]      = item
              end
            end
          end
        end
      end
      multifput "get ##{@teleporter[:item].id}", "turn ##{@teleporter[:item].id}", "_drag ##{@teleporter[:item].id} ##{@teleporter[:container]}" if @teleporter[:item]
      self
    end

    def wealth
      fput "info"
      while(line=get)
        next                if line =~ /^\s*Name\:|^\s*Gender\:|^\s*Normal \(Bonus\)|^\s*Strength \(STR\)\:|^\s*Constitution \(CON\)\:|^\s*Dexterity \(DEX\)\:|^\s*Agility \(AGI\)\:|^\s*Discipline \(DIS\)\:|^\s*Aura \(AUR\)\:|^\s*Logic \(LOG\)\:|^\s*Intuition \(INT\)\:|^\s*Wisdom \(WIS\)\:|^\s*Influence \(INF\)\:/
        if line =~ /^\s*Mana\:\s+\-?[0-9]+\s+Silver\:\s+([0-9]+)/
          @silvers= $1.to_i
          break
        end
        sleep 0.1
      end
      @silvers
    end

    def deplete(silvers)
      @silvers = @silvers - silvers
    end

    def smart_wealth
      return @silvers if @silvers 
      @wealth
    end

    def unhide
      fput 'unhide' if Spell[9003].active? or hidden?
      self
    end

    def withdraw(amount)
      go2_bank
      result = Olib.do "withdraw #{amount} silvers", /I'm sorry|then hands you/
      if result =~ /I'm sorry/ 
        go2_origin
        echo "Unable to withdraw the amount requested for this script to run from your bank account"
        exit
      end
      return self
    end

    def deposit_all
      self.go2_bank
      fput "unhide" if invisible? || hidden?
      fput "deposit all"
      return self
    end

    def deposit(amt)
      self.go2_bank
      fput "unhide" if invisible? || hidden?
      fput "deposit #{amt}"
      return self
    end

    # naive share
    # does not check if you're actually in a group or not
    def share
      wealth
      fput "share #{@silvers}"
      self
    end

    def go2(roomid)
      unhide if hidden
      unless Room.current.id == roomid
        start_script 'go2', [roomid, '_disable_confirm_']
        wait_while { running? "go2" };
      end
      return self
    end

    def hide
      while not hiding?
        waitrt?
        fput 'hide'
      end
    end

    def __constructor__
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

    # TODO
    # create a dictionary of house lockers and the logic to enter a locker
    # insure locker is closed before scripting away from it
    def go2_locker
      echo "the go2_locker method currently does not function properly..."
      self
    end

    def go2_origin
      if Room.current.id != @origin[:roomid]
        start_script 'go2', [@origin[:roomid]]
        wait_while { running? "go2" };
      end
      hide if @origin[:hidden]
      return self
    end    

  end
end