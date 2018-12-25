module Olib
  @@xml = false
  # invoke update notifier immediately
  # Olib.update_notifier
  def Olib.do(action, re)
    dothistimeout action, 5, re
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
          current_thread.raise Errors::TimedOut
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
      Olib.timeout(3) do
        put action if action
        while (line=get)
          next if Dictionary.ignorable?(line)
          # attempt at removing PC action that turned out to be more harmful than good
          # next if not GameObj.pcs.nil? and line =~ /#{GameObj.pcs.join('|')}/
          yield line
        end
      end
    rescue Errors::TimedOut
      # Silent
    rescue Errors::Mundane => e
    rescue Errors::Prempt => e
    end
  end

  def Olib.wrap_greedy(action)
    begin
      Olib.timeout(3) do
        put action
        while (line=get)
          yield line
        end
      end
    rescue Errors::TimedOut
      # Silent
    rescue Errors::Mundane => e
      # omit
    rescue Errors::Prempt => e
      # omit
    end
  end

  def Olib.exit
    raise Errors::Mundane
  end

  def Olib.wrap_stream(action = nil)
    begin
      Olib.turn_on_xml

      Olib.timeout(3) {
        if action then fput action end
        while (line=get)
          next if     Dictionary.ignorable?(line)
          # next if not GameObj.pcs.nil? and line =~ /#{GameObj.pcs.join('|')}/
          yield line
        end
      }
  
    rescue Errors::TimedOut
      # Silent
    rescue Errors::Mundane => e
      # omit
    rescue Errors::Prempt => e
      # omit
    ensure
      Olib.turn_off_xml
    end
  end
end