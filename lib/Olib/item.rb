require 'Olib/extender'
require 'Olib/dictionary'

module Olib
  # special item wrapper class to wrap item types with custom, common interactions becoming syntactic sugar
  class Item < Gameobj_Extender

    def take
      result = Olib.do "get ##{@id}", /#{[Olib::Gemstone_Regex.get[:success], Olib::Gemstone_Regex.get[:failure].values].flatten.join('|')}/
      if result =~ Olib::Gemstone_Regex.get[:failure][:buy]
        while(line=get)
          if line =~ /However, it'll be ([0-9]+) silvers for someone like you/
            @cost = $1.to_i
            @buyable = true
            break;
          elsif line =~ /The selling price is ([0-9]+) silvers/
            @cost = $1.to_i
            @buyable = true
            break; 
          end 
          break;
        end
      end
      result
    end

    def wear
      result = Olib.do "wear ##{@id}", /You can only wear|^You put|^You slide|^You attach|^You hang/
      if result =~ /You can only wear/
        return false
      else
        return true
      end
    end

    def remove; fput "remove ##{@id}";                  self; end

    def buy   ; fput "buy ##{@id}";                     self; end

    def give(target); fput "give ##{@id} to #{target}"; self; end

    def _drag(target)
      Olib.do "_drag ##{@id} ##{target.id}", /#{[Olib::Gemstone_Regex.put[:success], Olib::Gemstone_Regex.put[:failure].values].flatten.join("|")}/
    end

  end
end