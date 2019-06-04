require "Olib/pattern_matching/pattern_matching"

module Containers
  @@containers ||= {}

  def self.find_game_obj!(pattern)
    candidates = GameObj.inv.select do |item|
      if pattern.class.is_a?(String)
        item.name.include?(pattern)
      else
        item.name.match(pattern)
      end
    end
    case candidates.size
    when 1
      return Container.new(candidates.first)
    when 0
      fail Exception, <<~ERROR
        Source(GameObj.inv)

         reason: no matches for Pattern(#{pattern}) found in GameObj.inv
      ERROR
    else
      fail Exception, <<~ERROR
        Source(GameObj.inv)

         reason: aspecific Container[#{pattern.to_s}] found
        matches: #{candidates.map(&:name)}
      ERROR
    end
  end

  def self.define(name)
    var = Vars[name.to_s] or fail Exception, "Var[#{name}] is not set\n\t;vars set #{name}=<whatever>"
    pattern = %r[#{var}]
    @@containers[name] = Containers.find_game_obj!(pattern)
    @@containers[name]
  end

  def self.[](name)
    return define(name) if name.is_a?(Symbol)
    find_game_obj!(name)
  end

  def self.right_hand
    Container.new(Char.right)
  end

  def self.left_hand
    Container.new(Char.left)
  end

  def self.registry
    @@containers
  end

  def self.method_missing(name, *args)
    return @@containers[name] if @@containers[name]
    return self.define(name)
  end
end