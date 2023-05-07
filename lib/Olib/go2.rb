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

module Go2
  ##
  ## @brief      returns the filtered relevant Map db tags
  ##
  ## @return     Array
  ##
  def Go2.tags
    Map.tags.select { |tag| !tag.include? "=" }.uniq
  end

  ##
  ## dynamically assign all of our Go2#methods
  ##
  Go2.tags.each do |tag|    
    Go2.define_singleton_method(tag.methodize) do Go2.room(tag) end
  end

  def Go2.run(target)
    Script.run "go2", ("%s _disable_confirm_" % target)
  end

  def Go2.room(target)
    starting_room = Room.current.id
    unless Room.current.id == target || Room.current.tags.include?(target)
      Char.unhide if hidden
      Go2.run(target)
      if block_given?
        yield
        starting_room
      end
    end
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