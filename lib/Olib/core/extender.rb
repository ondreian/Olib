# used to wrap and extend a GameObj item
module Olib
  class Gameobj_Extender
    attr_accessor :type
    def initialize(item)
      self.__extend__(item)
      @type = item.type
    end

    # This copies GameObj data to attributes so we can employ it for scripting
    def __extend__(item)
      item.instance_variables.each { |var|
        s = var.to_s.sub('@', '')
        (class << self; self end).class_eval do; attr_accessor "#{s}"; end
        instance_variable_set "#{var}", item.send(s)
      }
    end

    def echo
      respond self
      self
    end

    def at
      fput "look at ##{@id}"
    end
  end
end