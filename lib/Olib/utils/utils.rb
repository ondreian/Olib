module Olib
  @@debug  = false
  @@xml    = false
  

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

  def Olib.wrap(action)
    
    begin
      Olib.timeout(3) {
        put action
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

  def Olib.wrap_stream(action, seconds=3)
    begin
      Olib.turn_on_xml

      Olib.timeout(seconds) {
        put action
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