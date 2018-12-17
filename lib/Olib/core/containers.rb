require "Olib/pattern_matching/pattern_matching"

module Containers
  @@containers = {}

  def self.find_game_obj!(name)
    var     = Vars[name.to_s] or fail Exception, "Var[#{name}] is not set\n\t;vars set #{name}=<whatever>"
    pattern = %r[#{var}]
    GameObj.inv.find(&Where[name: pattern]) or fail Exception, "#{name.capitalize}(#{var}) could not be found in GameObj.inv"
  end

  def self.define(name)
    @@containers[name] = Container.new(
      Containers.find_game_obj!(name))
    @@containers[name]
  end

  def self.method_missing(name, *args)
    return @@containers[name] if @@containers[name]
    return self.define(name)
  end

  def self.[](name)
    begin
      self.define(name)
    rescue Exception => err
      Err(why: err.message, error: err)
    end
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
end