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

  def self.cmd(cmd)
    XML.tap do 
      fput(cmd)
      while line = get
        yield(line)
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