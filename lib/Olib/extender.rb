# used to wrap and extend a GameObj item
module Olib
  class Gameobj_Extender
    attr_accessor :cost, :buyable
    def initialize(item)
    #  @type = item.type
       self.__extend__(item)
    end

    # This copies GameObj data to attributes so we can employ it for scripting
    def __extend__(item)
      item.instance_variables.each do |var|
        s = var.to_s.sub('@', '')
        (class << self; self end).class_eval do; attr_accessor "#{s}"; end
        instance_variable_set "#{var}", item.send(s)
      end
    end
  end

  # for 'get' but get is a reserved
  def get
    result = Olib.do "get ##{@id}", /#{[Gemstone_Regex.get[:success], Gemstone_Regex.get[:failure].values].flatten.join('|')}/
    if result =~ Gemstone_Regex.get[:failure][:buy]
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
end