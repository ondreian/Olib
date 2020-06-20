class Scroll < Exist
  SPELL = %r[\((?<num>\d+)\)\s(?<name>(\w|\s)+)$]

  def initialize(obj, container = nil)
    super(obj.id)
    @knowledge = nil
    @container = container
  end

  def spells()
    @_spells ||= _read()
  end

  def knowledge?
    spells
    @knowledge.eql?(true)
  end

  def _read()
    Script.current.want_downstream_xml = true
    dothistimeout("read ##{id}", 5, /It takes you a moment to focus on the/)
    spells = []
    @knowledge = false
    while line = get
      @knowledge = true if line.include?(%[in vibrant ink])
      break if line =~ %r[<prompt]
      _parse_spell(spells, line.strip)
    end
    Script.current.want_downstream_xml = false
    return spells
  end

  def _parse_spell(spells, line)
    return unless line =~ SPELL
    spells << OpenStruct.new(line.match(SPELL).to_h)
  end
end