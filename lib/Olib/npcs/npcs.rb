require "Olib/npcs/npc"
# a collection for managing all of the npcs in a room

class NPCS
  include Enumerable

  ALL = -> npc { true }

  attr_reader :predicate

  def initialize(&predicate)
    @predicate = predicate
  end

  def each()    
    GameObj.npcs.to_a.map do |obj| NPC.new(obj) end
      .select(&@predicate)
      .each do |npc| yield(npc) unless npc.tags.include?(:aggressive) end
  end

  def respond_to_missing?(method, include_private = false)
    to_a.respond_to?(method) or super
  end

  def method_missing(method, *args)
    if to_a.respond_to?(method)
      to_a.send(method, *args)
    else
      super(method, *args)
    end
  end

  def self.method_missing(method, *args, &block)
    if respond_to?(method)
      NPCS.new.send(method, *args, &block)
    else
      super(method, *args, &block)
    end
  end

  def self.respond_to?(method)
    return super(method) unless NPCS.new.respond_to?(method)
    return true
  end
end
