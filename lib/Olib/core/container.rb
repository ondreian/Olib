# for defining containers ala lootsack and using them across scripts

require "Olib/core/extender"
require "Olib/core/item"

class Regexp
  def or(re)
    Regexp.new self.to_s + "|" + re.to_s
  end
end

def class_exists?(class_name)
  klass = Module.const_get(class_name)
  return klass.is_a?(Class)
rescue NameError
  return false
end

module Olib
  class Container < Gameobj_Extender
    attr_accessor :ref, :nested, :containers, :ontop

    
    Item.type_methods.each { |method, tag|
      define_method(method.to_sym) do
        find_by_tags(tag)
      end
    }


    def initialize(id=nil)
      # extract the class name to attempt to lookup the item by your settings
      # ex: class Lootsack
      # ex: class Gemsack
      name       = if self.class.name.include?("::") then self.class.name.downcase.split("::").last.strip else self.class.name.downcase end 
      candidates = Olib.Inventory[Vars[name]]
      raise Olib::Errors::DoesntExist.new("#{name} could not be initialized are you sure you:\n ;var set #{name}=<something>") if candidates.empty? && id.nil?

      @ref   = GameObj[id] || candidates.first
      @ontop = Array.new
      
      unless GameObj[@ref.id].contents
        tops = [
          "table"
        ]

        action = tops.include?(@ref.noun) ? "look on ##{@ref.id}" : "look in ##{@ref.id}"
         
        fput action
      end
      
      super @ref
            
    end

    def contents
      [
        @ontop,
        GameObj[@ref.id].contents.map { |item| 
          Item.new(item) 
        }
      ].flatten
    end

    def where(conditions)
      contents.select { |item|
        !conditions.keys.map { |key|
          if conditions[key].class == Array
            item.props[key].class == Array && !conditions[key].map { |ele| item.props[key].include? ele }.include?(false)
          else
            item.props[key] == conditions[key]
          end
        }.include?(false)
      }
    end

    def find_by_tags(*tags)  
      contents.select { |item|
        !tags.map {|tag| item.is?(tag) }.include?(false)
      }
    end


    def [](query)
      return contents.select do |item| 
        item if (item.type =~ query || item.noun =~ query || item.name =~ query)
      end
    end

    def 

    def __verbs__
      @verbs = "open close analyze inspect weigh".split(" ").map(&:to_sym)
      singleton = (class << self; self end)
      @verbs.each do |verb|
        singleton.send :define_method, verb do
          fput "#{verb.to_s} ##{@id}"
          self
        end
      end
    end

    def at
      Olib.wrap_stream("look at ##{@id}") { |line|
        if line =~ /You see nothing unusual|prompt time|You gaze through (.*?) and see...|written/
          raise Olib::Errors::Mundane
        end

        if line =~ /Looking at the (.*?), you see (?<nested>.*)/
          @nested = true

          @containers = line
            .match(/Looking at the (.*?), you see (?<nested>.*)/)[:nested]
            .scan(/<a exist="(?<id>.*?)" noun="(?<noun>.*?)">(?<name>.*?)<\/a>/)
            .map {|matches| Container.new GameObj.new *matches }
          raise Olib::Errors::Mundane
        end
        
      }
      self
    end

    def look
      self
    end

    def on
      return self unless @id
      Olib.wrap_stream("look on ##{@id}") { |line|
        raise Olib::Errors::Mundane if line =~ /There is nothing on there|prompt time/
        if line =~ /On the (.*?) you see/
          @ontop << line.match(Dictionary.contents)[:items]
            .scan(Dictionary.tag)
            .map {|matches| Item.new GameObj.new *matches }
          raise Olib::Errors::Mundane
        end
        next
      }
      self
    end

    def in
      fput "look in ##{@id}"
      self
    end

    def rummage
      Rummage.new(self)
    end

    def nested?
      @nested
    end

    def full?
      is? "full"
    end

    def add(*items)
      _id = @id
      items.each { |item|
        result = Olib.do "_drag ##{item.id} ##{_id}", /#{[Olib::Dictionary.put[:success], Olib::Dictionary.put[:failure].values].flatten.join("|")}/
        if result =~ /won"t fit in the/
          tag "full"
          raise Errors::ContainerFull
        end
      }
      self
    end
  end
end

class Rummage
  SUCCESS = /and remove/
  FAIL    = /but can't seem|^But your hands are full|^You can only rummage for|^What/

  @@message = OpenStruct.new(
    success: SUCCESS,
    fail: FAIL,
    either: SUCCESS.or(FAIL)
  )

  def Rummage.message
    @@message
  end

  attr_accessor :container

  def initialize(container)
    @container = container
  end

  def perform(mod, query)
    res = Olib.do "rummage ##{@container.id} #{mod} #{query}", Rummage.message.either
    [!res.match(FAIL), res]
  end

  def spell(number)
    perform "spell", number
  end

  def runestone(rune)
    perform "runestone", rune
  end

  def ingredient(str)
    perform "ingredient", str
  end

  def holy(tier)
    perform "holy", tier
  end
end

module Containers
  @@containers = {}

  def Containers.define(name)
    @@containers[name] = Object.const_set(name.capitalize, Class.new(Olib::Container)).new
    @@containers[name]
  end

  def Containers.method_missing(name)
    return @@containers[name] if @@containers[name]
    return Containers.define(name)
  end

end