require "Olib/ext/string"

class Integer
  def go2
    Go2.room self
  end  
end

class String
  def go2
    Go2.room self
  end  
end

class Go2
  ##
  ## @brief      returns the filtered relevant Map db tags
  ##
  ## @return     Array
  ##
  def Go2.tags
    Map.tags.select { |tag| !tag.include? "=" }
  end

  ##
  ## dynamically assign all of our Go2#methods
  ##
  Go2.tags.each do |tag|    
    Go2.define_singleton_method(tag.methodize) do Go2.room(tag) end
  end

  def Go2.room(roomid)
    unless Room.current.id == roomid || Room.current.tags.include?(roomid)
      Char.unhide if hidden
      start_script "go2", [roomid, "_disable_confirm_"]
      wait_while { running? "go2" };
    end
    Go2
  end

  def Go2.origin
    Go2.room @@origin[:roomid]
    Char.hide if @@origin[:hidden]
    Go2
  end

  def Go2.rebase
    @@origin            = {}
    @@origin[:roomid]   = Room.current.id
    @@origin[:hidden]   = hiding?
    @@origin[:location] = Room.current.location
    Go2
  end

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
end