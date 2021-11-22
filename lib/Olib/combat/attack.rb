require "ostruct"

module Attack
  # AS: +491 vs DS: +195 with AvD: +25 + d100 roll: +80 = +401
  AS_DS_PATTERN = /AS: (?<as>.*) vs DS: (?<ds>.*) with AvD: (?<avd>.*) \+ d100 roll: (?<roll>.*) = (?<total>.*)$/
  CS_TD_PATTERN = /CS: (?<cs>.*) \- TD: (?<td>.*) \+ CvA: (?<cva>.*) \+ d100: (?<roll>.*) == (?<total>.*)$/

  @template = Rill.union(
    %[You (.*?) at <pushBold/>(a|an|some) <a exist="{{id}}],
    %[A little bit late],
    %[already dead], 
    %[You don't have a spell prepared!],
    %[I could not find what you were referring to],
    %[You position yourself to attack],
    %[What were you referring to?])

  @matcher = Rill.new(timeout: 2, start: @template)
  
  def self.apply(creature, verb, qstrike: 0)
    begin
      return [:err, :dead] if creature.dead?
      waitrt?
      waitcastrt?
      return [:err, :dead] if creature.dead?
      code, lines = @matcher.capture(creature.to_h, build_command(verb, qstrike))
      return parse_result(lines) unless lines.empty?
      return code
    rescue => exception
      return [:err, exception]
    end
  end

  def self.build_command(verb, qstrike)
    return %[#{verb} \#{{id}}] if qstrike.eql?(0)
    return %[qstrike #{qstrike} #{verb} \#{{id}}]
  end
  
  def self.parse_result(lines)
    as_ds = lines.find {|line| line =~AS_DS_PATTERN}
    return [:ok, parse_as_ds(as_ds)] if as_ds
    cs_td = lines.find {|line| line =~CS_TD_PATTERN}
    return [:ok, parse_cs_td(cs_td)] if cs_td
    return [:err, :unknown]
  end

  def self.parse_cs_td(line)
    resolution = OpenStruct.new line.match(CS_TD_PATTERN).to_h
    resolution[:likelihood] = (resolution.cs + resolution.cva) - resolution.td
    return resolution
  end

  def self.parse_as_ds(line)
    resolution = OpenStruct.new line.match(AS_DS_PATTERN).to_h
    resolution[:likelihood] = (resolution.as + resolution.avd) - resolution.ds
    return resolution
  end
end