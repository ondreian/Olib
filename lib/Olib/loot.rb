class Loot
  include Enumerable

  ALL = -> item { true }

  attr_reader :predicate

  def initialize(&predicate)
    @predicate = predicate
  end

  def each()    
    GameObj.loot.to_a.map do |obj| Item.new(obj) end
      .reject(&Where[noun: "disk"])
      .select(&@predicate)
      .each do |item| yield(item) end
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
      Loot.new.send(method, *args, &block)
    else
      super(method, *args, &block)
    end
  end

  def self.respond_to?(method)
    return super(method) unless Loot.new.respond_to?(method)
    return true
  end
end
