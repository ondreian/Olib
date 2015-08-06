class ScriptVars
  attr_accessor :opts
  def initialize
    opts          = {}
    opts[:flags]  = {}
    return opts if Script.current.vars.empty?
    list          = Script.current.vars.map(&:downcase).last(Script.current.vars.length-1)
    unless list.first.start_with?('--')
      opts[:cmd]   = list.shift
    end
    # iterate over list for flag values
    
    list.each.with_index {|ele, i|
      if ele.start_with?('--')
        opts[:flags][ symbolize(ele) ] = ''
      else
        # cast to Number if is number
        ele = ele.to_i if ele =~ /^([\d\.]+$)/
        # look back to previous flag and set it to it's value
        opts[:flags][ symbolize(list[i-1]) ] = ele
      end
    }
    
    @opts = opts
    self
  end

  def cmd
    @opts[:cmd]
  end

  def empty?(flag)
    opts[:flags][flag].class == TrueClass || opts[:flags][flag].class == NilClass
  end

  def cmd?(action)
    cmd == action
  end

  def symbolize(flag)
    flag.gsub('--', '').gsub('-', '_').to_sym
  end

  def help?
    cmd =~ /help/
  end

  def flags
    opts[:flags].keys
  end

  def to_s
    @opts.to_s
  end

  def flag
    self
  end

  def flag?(f)
    opts[:flags][ symbolize(f) ]
  end

  def method_missing(arg1, arg2=nil)
    @opts[:flags][arg1]
  end

end

module Olib
  def Olib.CLI
    ScriptVars.new
  end
end