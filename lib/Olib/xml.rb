##
## XML utils
##
module XML
  def self.xml_on
    Script.current.want_downstream_xml = true
  end

  def self.xml_off
    Script.current.want_downstream_xml = false
  end

  def self.tap
    xml_on
    result = yield
    xml_off
    result
  end

  def self.cmd(cmd, timeout: 5, pattern:)
    XML.tap do 
      result = dothistimeout(cmd, timeout, pattern)
      return nil if result.nil?
      yield(result)
      ttl = Time.now + timeout
      while line = get
        yield(line)
        break if Time.now > ttl
      end
    end
  end

  def self.lines(**opts, &block)
    XML.tap do 
      while line = get
        result = block.call(line)
        break if result == :halt
      end
    end
  end

  def self.match(cmd, patt, timeout: 5)
    XML.tap do
      dothistimeout(cmd, timeout, patt)
    end
  end
end