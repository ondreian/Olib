require "ostruct"
require "Olib/core/exist"
require "Olib/core/use"
require "Olib/core/transaction"
require "Olib/core/scroll"

class GameObj
  def to_item
    Item.new self
  end
end

# this is the structure for a base Object
# wraps an instance of GameObj and adds the ability for tags, queries
class Item < Exist
  def self.of(item, container = nil)
    return Scroll.new(item, container) if item.type.include?("scroll")
    return Item.new(item, container)
  end


  def self.fetch(id)
    new Exist.fetch(id)
  end

  attr_reader :container
  # When created, it should be passed an instance of GameObj
  #
  # Example: 
  #          Item.new(GameObj.right_hand)
  def initialize(obj, container = nil)
    super(obj.id)
    @container = container
  end

  def worn?
    GameObj.inv.map(&:id).include?(id)
  end

  def use(&block)
    Use.new(self, &block)
  end

  def held?
    [Char.left, Char.right].map(&:id).include?(id.to_s)
  end

  def take()
    return self if held?
    fail Exception, "Error #{inspect}\nyour hands are full" if Char.left && Char.right
    Action.try_or_fail(command: "get ##{id}") do held? end
    return self
  end

  def to_json(*args)    
    to_h.to_json(*args)
  end

  def transaction(**args)
    Transaction.new(take, **args)
  end

  def appraise(**args)
    transaction(**args).appraise()
  end

  def sell(**args)
    transaction(**args).sell()
  end

  def stash
    @container.add(self) unless @container.nil?
  end
end