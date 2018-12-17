require "Olib/ext/matchdata"

class Outcome
  HANDLEBARS = %r[{{(?<var>.*?)}}]

  def self.union(outcomes, **vars)
    Regexp.union(outcomes.map do |outcome| outcome.prepare(**vars) end)
  end

  def self.prepare(template, vars)
    template.gsub(HANDLEBARS) do |name|
      name = name.match(HANDLEBARS).to_struct.var.to_sym
      if vars.respond_to?(name)  
        vars.send(name) 
      elsif vars.respond_to?(:fetch) 
        vars.fetch(name)
      elsif vars.respond_to?(:[])
        vars[name]
      else
        raise Exception.new "could not serialize var: #{name} of #{vars.class.name} in Outcome"
      end
    end
  end

  attr_reader :template

  def initialize(template)
    @template = template
  end
  
  def prepare(vars)
    return @template if @template.is_a?(Regexp)
    %r[#{Outcome.prepare(@template, vars)}]
  end
end