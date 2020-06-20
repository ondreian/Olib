require "Olib/pattern_matching/rill"

class Transaction < Exist
  Appraise = Rill.new(
    start: %[to appraise (?:a |an |)<a exist="{{id}}"],
    close: Regexp.union(
      %r[I already appraised that],
      %r[Sorry, #{Char.name}, I'm not buying anything this valuable today\.],
      %r[(I'll give you|How's|I'll offer you|worth at least) (?<value>\d+)],
      %r[(?<value>\d+) silvers])
    )
  
  Sell = Rill.new(
    start: %[You offer|You ask (?<merchant>.*?) if (he|she) would like to buy (?:a |an |)<a exist="{{id}}"],
    close: Regexp.union(
      %r[(hands you|for) (?<value>\d+)],
      %r[No #{Char.name}, I won't buy that],
      %r[I'm sorry, #{Char.name}, but I have no use for that\.],
      %r[He hands it back to you],
      %r[Nope #{Char.name}, I ain't buying that\.],
      %r[basically worthless here, #{Char.name}])
    )
  
  attr_reader :value,
              :threshold

  def initialize(item, **args)
    super(item)
    @threshold = args.fetch(:threshold, false)
  end

  def take()
    Item.new(self).take
    self
  end

  def appraise()
    return self unless @value.nil?
    take
    (_, match, lines) = Appraise.capture(self.to_h, 
      "appraise \#{{id}}")
    if lines.any? {|line| line.include?(%[Sorry, Pixelia, I'm not buying anything this valuable today.])}
      @value = Float::INFINITY
    else
      @value = match[:value].to_i
    end
    self
  end

  def sell()
    take
    if @threshold && appraise && @value > @threshold
      return Err[
        transaction: self,
        reason:      "Value[#{@value}] is over Threshold[#{@threshold}]"] 
    end
  
    (_, match, _lines) = Sell.capture(self.to_h, 
      "sell \#{{id}}")

    
    match[:value] = 0 unless match[:value].is_a?(Integer)
    Ok[**match]
  end
end