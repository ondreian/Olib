require "Olib/pattern_matching/any"

class Result
  def self.included(ctx)
    ctx.include(Result::Constructors)
    ctx.extend(Result:Constructors)
  end

  def self.of(); -> val { self.new(val); }; end
  class << self; alias :[] :new; end

  def self.compare(this, other)
    return _match_class(this, other)  if other.is_a?(Class)
    return _match_result(this, other) if this.is_a?(Result) and other.is_a?(Result)
    return _compare_object_shape(this.val, other) if this.val.is_a?(Object) and other.is_a?(Hash)
    return _compare_object_shape(other, this.val) if this.val.is_a?(Hash) and other.is_a?(Object)
    return _compare_values(this.val, other)
  end

  def self._match_class(this, other)
    return this.is_a?(other) if [Err, Ok].include?(other)
    this.val.is_a?(other)
  end

  def self._compare_values(left, right)
    left == Any || right == Any || left === right
  end

  def self._compare_object_shape(this, expected)
    fail "expected Shape(#{expected.inspect}) must be a Hash" unless expected.is_a?(Hash)
    ## fail fast when not possible to be true
    return false if this.is_a?(Hash) and expected.size > this.size
    ## compare all keys
    expected.all? do |k, v|
      if this.respond_to?(k.to_sym)
        _compare_values(v, this.send(k.to_sym))
      elsif this.respond_to?(:[])
        _compare_values(v, this[k.to_s]) or _compare_values(v, this[k.to_sym])
      else
        false
      end
    end
  end

  def self._match_result(this, other)
    return false unless this.is_a?(other.class)
    return _compare_object_shape(this.val, other.val) if this.val.is_a?(Object) and other.val.is_a?(Hash)
    return _compare_values(this.val, other.val)
  end

  attr_reader :val

  def initialize(val)
    @val = val
  end

  def ==(other)
    self.===(other)
  end

  def ===(other)
    Result.compare(self, other)
  end

  def to_json(*args)
    @val.to_json(*args)
  end

  def to_proc
    -> other { Result.compare(self, other) }
  end

  module Constructors
    def Ok(*args)
      Ok[*args]
    end

    def Err(*args)
      Err[*args]
    end
  end
end