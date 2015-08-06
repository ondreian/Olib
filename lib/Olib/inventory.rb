module Olib
  module Inventory
    Vars.Olib[:Inventory] ||= Hash.new

    @@checked = false

    
    def Inventory.containers
      Inventory.check
      GameObj.containers
    end


    def Inventory.checked?
      @@checked
    end

    def Inventory.[](query)
      GameObj.inv.select { |item|
        item.name == query || item.id == query
      }
    end

    def Inventory.teleporter
      # check for worn teleporter
      candidates= GameObj.inv.select { |item|
        item.name == Vars.teleporter
      }

      unless candidates.empty?
        return Item.new(candidates.first)
      end

      # check in containers
      Inventory.items.select { |item|
        item.is? "teleporter"
      }.first
    end
    
    def Inventory.items
      Inventory.containers.map { |id, contents| contents.map {|item|
          Item.new(item).define("container", id)
        } 
      }.flatten
    end

    def Inventory.check
      return self if Inventory.checked?
      GameObj.inv.select{ |item|
        !item.name.include?('tattoo')
      }.each {|item|
        if item.contents.nil?
          Olib.wrap("look in ##{item.id}") { |line|
            respond line =~ /Shadow engulf/

            raise Olib::Errors::Mundane if line =~ /There is nothing in there.|Total|^In the (.*).$|prompt|^Shadows engulf/

            if line =~ /That is closed./
              Olib.wrap("open ##{item.id}") { |line|
                if line =~ /You open/
                  multifput "look in ##{item.id}", "close ##{item.id}"
                end
              } 
            end
          }
        end
      }
      @@checked = true
      return self
    end
  
  end

  def Olib.Inventory
    Olib::Inventory
  end
end