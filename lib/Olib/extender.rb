# used to wrap and extend a GameObj item
module Olib
  class Gameobj_Extender
    #attr_accessor :type
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
end