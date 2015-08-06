# for defining containers ala lootsack and using them across scripts

require 'Olib/core/extender'

class String
  def to_class
    Kernel.const_get self
  rescue NameError 
    nil
  end

  def is_a_defined_class?
    true if self.to_class
  rescue NameError
    false
  end
end

module Olib
  class Container < Gameobj_Extender
    attr_accessor :ref

    def initialize(id=nil)
      # extract the class name to attempt to lookup the item by your settings
      # ex: class Lootsack
      # ex: class Gemsack
      name       = self.class.name.downcase.split('::').last.strip
      candidates = Olib.Inventory[Vars[name]]
      raise Olib::Errors::DoesntExist.new("#{name} could not be initialized are you sure you:\n ;var set #{name}=<something>") if candidates.empty? && id.nil?

      @ref = GameObj[id] || candidates.first
      
      unless GameObj[@ref.id].contents
        tops = [
          'table'
        ]

        action = tops.include?(@ref.noun) ? "look on ##{@ref.id}" : "look in ##{@ref.id}"
         
        fput action
      end
      
      super @ref
            
    end

    def contents
      GameObj[@ref.id].contents.map{ |item| Item.new(item) }
    end

    def where(conditions)        
      contents.select { |item|
        conditions.keys.map { |key|
          item.respond_to?(key) ? item.send(key) == conditions[key] : false
        }.include? false
      }
    end

    def find_by_tags(*tags)  
      contents.select { |item|
        !tags.map {|tag| item.is?(tag) }.include? false
      }
    end


    def [](query)
      return contents.select do |item| 
        item if (item.type =~ query || item.noun =~ query || item.name =~ query)
      end
    end

    def 

    def __verbs__
      @verbs = 'open close analyze inspect weigh'.split(' ').map(&:to_sym)
      singleton = (class << self; self end)
      @verbs.each do |verb|
        singleton.send :define_method, verb do
          fput "#{verb.to_s} ##{@id}"
          self
        end
      end
    end

    def full?
      is? 'full'
    end

    def add(item)
      result = Olib.do "_drag ##{item.id} ##{@id}", /#{[Olib::Dictionary.put[:success], Olib::Dictionary.put[:failure].values].flatten.join('|')}/
      tag 'full' if result =~ /won't fit in the/
      self
    end
  end

  class Lootsack < Container

  end

  @@lootsack = nil
    
  def Olib.Lootsack
    return @@lootsack if @@lootsack
    @@lootsack = Lootsack.new
    @@lootsack
  end
end