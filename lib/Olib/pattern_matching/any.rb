require "Olib/pattern_matching/result"

class Any < Result
  def self.===(*args)
    true
  end

  def ===(other)
    true
  end
end