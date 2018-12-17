require "Olib/xml"
require "Olib/pattern_matching/outcome"
require "Olib/ext/matchdata"

class Rill
  PROMPT = /<prompt/

  include Enumerable
  attr_reader :close, :start, :mode

  def initialize(start: nil, close: PROMPT, mode: :xml)
    fail "Rill.new() requires :start argument" if start.nil?
    @mode    = mode
    @close   = Outcome.new(close)
    @start   = Outcome.new(start)
  end

  def capture(obj, command_template)
    return capture_xml(obj, command_template) if mode.eql?(:xml)
    fail "non-XML mode not implemented yet"
  end

  def capture_xml(obj, command_template)
    begin_pattern = @start.prepare(obj)
    end_pattern   = @close.prepare(obj)
    command       = Outcome.prepare(command_template, obj)
    state         = :start
    lines         = []
    matches       = {}
    XML.cmd(command) do |line|
      state = :open  if line.match(begin_pattern)
      lines  << line if state.eql?(:open)
      if (result = (line.match(begin_pattern) || line.match(end_pattern)))
        matches.merge!(result.to_h)
      end
      return [matches, lines] if (line.match(end_pattern) and state.eql?(:open))
    end
  end

  def each(&block)
    @lines.each(&block)
  end
end