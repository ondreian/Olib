module Olib
  @@debug  = false
  @@xml    = false

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

  def Olib.vars
    ScriptVars.new
  end
  

  def Olib.toggle_debug
    @@debug = @@debug ? false : true 
  end

  def Olib.debug(msg)
    return unless @@debug
    echo "Olib.debug> #{msg}"
  end

  def Olib.timeout(sec)   #:yield: +sec+
    return yield(sec) if sec == nil or sec.zero?
  
    begin
      current_thread = Thread.current
      x = Thread.start{ 
        begin
          yield(sec)
        rescue => e 
          current_thread.raise e
        end
      }
      y = Thread.start {
        begin
          sleep sec
        rescue => e
          x.raise e
        else
          x.kill
          current_thread.raise Olib::Errors::TimedOut
        end
      }
      x.value
    ensure
      if y
        y.kill
        y.join # make sure y is dead.
      end
    end
    
  end

  def Olib.script
    Script.current
  end

  def Olib.turn_on_xml
    if not @@xml
      @@xml = true
      Script.current.want_downstream_xml = @@xml
    end
    self
  end

  def Olib.turn_off_xml
    if @@xml
      @@xml = false
      Script.current.want_downstream_xml = @@xml
    end
    self
  end

  def Olib.xml?
    @@xml
  end

  def Olib.wrap(action = nil)
    
    begin
      Olib.timeout(3) {
        put action if action
        while (line=get)
          next if Dictionary.ignorable?(line)
          # attempt at removing PC action that turned out to be more harmful than good
          # next if not GameObj.pcs.nil? and line =~ /#{GameObj.pcs.join('|')}/
          yield line
        end
      }

    rescue Olib::Errors::TimedOut
      Olib.debug "timeout... "
      # Silent
    rescue Olib::Errors::Mundane => e

    rescue Olib::Errors::Prempt => e
      
    end
    
  end

  def Olib.wrap_greedy(action)
    
    begin
      Olib.timeout(3) {
        put action
        while (line=get)
          #next if not GameObj.pcs.nil? and line =~ /#{GameObj.pcs.join('|')}/
          yield line
        end
      }

    rescue Olib::Errors::TimedOut
      Olib.debug "timeout... "
      # Silent
    rescue Olib::Errors::Mundane => e

    rescue Olib::Errors::Prempt => e
      
    end
    
  end

  def Olib.exit
    raise Olib::Errors::Mundane
  end

  def Olib.wrap_stream(action = nil)
    begin
      Olib.turn_on_xml

      Olib.timeout(3) {
        if action then fput action end
        while (line=get)
          next if     Olib::Dictionary.ignorable?(line)
          # next if not GameObj.pcs.nil? and line =~ /#{GameObj.pcs.join('|')}/
          yield line
        end
      }
  
    rescue Olib::Errors::TimedOut
      Olib.debug "timeout... "
      # Silent

    rescue Olib::Errors::Mundane => e
      Olib.debug "mundane..."

    rescue Olib::Errors::Prempt => e
      Olib.debug "waiting prempted..."

    ensure
      Olib.turn_off_xml
    end
  end
end