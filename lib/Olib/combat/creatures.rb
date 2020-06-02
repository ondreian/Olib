require 'json'
# a collection for managing all of the creatures in a room

class Creatures
  include Enumerable
  
  ARCHETYPES = %i[ 
    undead living weak
    grimswarm antimagic flying 
    lowly bandit aggressive
  ]

  STATES = %i[
    prone sitting kneeling
    sleeping webbed immobile
    stunned 
    flying
  ]

  KINDS = ARCHETYPES + STATES

  ALL = -> creature { true }

  attr_reader :predicate

  def initialize(&predicate)
    @predicate = predicate
  end

  def each()    
    GameObj.targets.to_a.map do |obj| Creature.new(obj) end
      .select(&@predicate)
      .each do |creature| yield(creature) if GameObj[creature.id] end
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

  KINDS.each do |kind|
    define_method(kind) do
      Creatures.new do |creature| [creature.tags, creature.status].flatten.include?(kind) end
    end
  end

  def bounty
    Creatures.new do |creature| creature.name.include?(Bounty.creature) end
  end

  def dead
    GameObj.npcs.to_a
      .select do |c| c.status.include?("dead") end
      .map do |obj| Creature.new(obj) end
  end

  def self.method_missing(method, *args, &block)
    if respond_to?(method)
      Creatures.new.send(method, *args, &block)
    else
      super(method, *args, &block)
    end
  end

  def self.respond_to?(method)
    return super(method) unless Creatures.new.respond_to?(method)
    return true
  end
end
