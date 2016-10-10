module Olib

  class Transport
    
    @@teleporter = {}
    @@routines   = {}
    @@tags = [
      'bank', 'gemshop', 'pawnshop', 'advguild', 'forge', 'inn', 'npchealer',
      'chronomage', 'town', 'furrier', 'herbalist', 'locksmith', 'alchemist',
      'fletcher', 'sunfist', 'movers', 'consignment', 'advguard','advguard2',
      'clericshop', 'warriorguild'
    ]

    def Transport.tags
      @@tags
    end

    def Transport.__extend__
      singleton = (class << self; self end)
      Transport.tags.each do |target|
        method = "go2_#{target}".to_sym

        singleton.send :define_method, method do
          Olib.Char.unhide if hidden?
          unless Room.current.tags.include?(target)
            start_script 'go2', [target, '_disable_confirm_']
            wait_while { running? "go2" };
          end
          return self
        end

        singleton.send :alias_method, target.to_sym, method
      end
    end

    Transport.__extend__

    def Transport.rebase
      @@origin            = {}
      @@origin[:roomid]   = Room.current.id
      @@origin[:hidden]   = hiding?
      @@origin[:location] = Room.current.location
      Olib.debug "rebasing to #{@@origin}"
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


    def Transport.go2(roomid)
      Olib.Char.unhide if hidden
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
      Transport.go2 @@origin[:roomid]
      Olib.Char.hide if @@origin[:hidden]
      return self
    end    

  end

  def Olib.Transport
    Olib::Transport
  end
end

class Go2 < Olib::Transport
  def Go2.room(num)
    Olib::Transport.go2 num
  end

  def Go2.origin
    Olib::Transport.go2_origin
  end

  def Go2.fwi
    Olib::Transport.fwi_teleport
  end
end