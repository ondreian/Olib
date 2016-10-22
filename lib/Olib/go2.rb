module Olib
  ##
  ## @brief      ;go2 wrapper class
  ##
  class Go2 
    @@teleporter = {}
    @@routines   = {}
    ##
    ## @brief      returns the filtered relevant Map db tags
    ##
    ## @return     Array
    ##
    def Go2.tags
      Map.tags
        .select { |tag| !tag.include? "=" }
    end

    ##
    ## dynamically assign all of our Go2#methods
    ##
    Go2.tags
      .each { |tag|
        method  = Olib.methodize tag
        go2_dep = "go2_#{method}"
        
        Go2.define_singleton_method(method.to_sym) do
          Go2.room tag
        end

        Go2.define_singleton_method(go2_dep.to_sym) do
          respond "[deprecation warning] Go2.#{go2_dep} => Go2.#{method}"
          Go2.room tag
        end
      }

    def Go2.room(roomid)
      Olib.Char.unhide if hidden
      unless Room.current.id == roomid
        start_script "go2", [roomid, "_disable_confirm_"]
        wait_while { running? "go2" };
      end
      Go2
    end

    def Go2.go2(roomid)
      respond "[deprecation warning] Go2.go2 => Go2.room"
      Go2.room(roomid)
    end

    def Go2.origin
      Go2.room @@origin[:roomid]
      Olib.Char.hide if @@origin[:hidden]
      Go2
    end

    def Go2.fwi
      unless Char.fwi_teleporter
        echo "Error: No teleport defined ;var set teleporter=<teleporter>"
        exit
      end
      
      unless Inventory.fwi_teleporter
        echo "Error: Your teleporter could not be found #{Go2.teleporter}"
        exit
      end

      last = Room.current.id
      teleporter = Inventory.fwi_teleporter
      if teleporter.worn?
        teleporter.turn
      else
        teleporter.take.turn.stash
      end

      if Room.current.id == last
        echo "Error: You tried to teleport to FWI in a room that does not allow that"
      end

      Go2
    end
  
    def Go2.rebase
      @@origin            = {}
      @@origin[:roomid]   = Room.current.id
      @@origin[:hidden]   = hiding?
      @@origin[:location] = Room.current.location
      Olib.debug "rebasing to #{@@origin}"
      Go2
    end

    Go2.rebase

    # Thanks Tillmen
    def Go2.cost(to)
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
    def Go2.fwi_teleport
      respond "[deprecation warning] Go2.fwi_teleport => Go2.fwi"
      Go2.fwi
    end

    # TODO
    # create a dictionary of house lockers and the logic to enter a locker
    # insure locker is closed before scripting away from it
    def Go2.locker
      echo "the go2_locker method currently does not function properly..."
      self
    end
    ##
    ## @brief      returns to the rebased room
    ## @deprecated
    ##
    ## @return     Go2
    ##
    def Go2.go2_origin
      respond "[deprecation warning] Go2.go2_origin => Go2.origin"
      Go2.fwi
    end    

  end

  def Olib.Go2
    Olib::Go2
  end

  class Transport < Go2
    respond "[deprecation warning] Olib::Transport => Olib::Go2 on next major release"
    # backwards compat
  end

end

class Go2 < Olib::Go2
  # expose on the global scope
end