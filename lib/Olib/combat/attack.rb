require "ostruct"

module Attack
  AS_DS_PATTERN = /AS: (?<as>.*) vs DS: (?<ds>.*) with AvD: (?<avd>.*) \+ d100 roll: (?<roll>.*) = (?<total>.*)$/
  CS_TD_PATTERN = /CS: (?<cs>.*) \- TD: (?<td>.*) \+ CvA: (?<cva>.*) \+ d100: (?<roll>.*) == (?<total>.*)$/

  @template = Rill.union(
    %[You (.*?) at <pushBold/>(a|an|some) <a exist="{{id}}],
    %[A little bit late],
    %[already dead], 
    %[You don't have a spell prepared!],
    %[I could not find what you were referring to],
    %[What were you referring to?])

  @matcher = Rill.new(timeout: 2, start: @template)
  
  def self.apply(creature, verb, qstrike: 0)
    begin
      return [:err, :dead] if creature.dead?
      waitrt?
      waitcastrt?
      return [:err, :dead] if creature.dead?
      case @matcher.capture(creature.to_h, build_command(verb, qstrike))
      in [:ok, _, []]
        return [:noop]
      in [:ok, _, lines]
        parse_result(lines)
      end  
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
    Log.out(resolution)
    resolution[:likelihood] = (resolution.cs + resolution.cva) - resolution.td
    return resolution
  end

  def self.parse_as_ds(line)
    resolution = OpenStruct.new line.match(AS_DS_PATTERN).to_h
    resolution[:likelihood] = (resolution.as + resolution.avd) - resolution.ds
    return resolution
  end
end