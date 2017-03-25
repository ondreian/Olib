##
## @brief      pattern matching for Ruby
##
class Pattern
  attr_accessor :cases

  def initialize(cases)
    @cases = cases
  end

  def match(str)
    found = @cases.each_pair.find do |exp, handler|
      str =~ exp
    end

    if !found
      raise Exception.new [
        "Error: inexhaustive pattern",
        "counterexample: #{str}",
      ].join("\n")
    end

    exp, handler = found

    handler.call exp.match(str).to_struct
  end

  def to_proc
    patt = self
    Proc.new do |str|
      patt.match str
    end
  end
end