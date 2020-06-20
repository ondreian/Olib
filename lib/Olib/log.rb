module Preset
  def self.as(kind, body)
    %[<preset id="#{kind}">#{body}</preset>\r\n]
  end
end
##
## contextual logging
##
module Log  
  require "cgi"
  def self.out(msg, label: :debug)
    return _write _view(msg, label) unless msg.is_a?(Exception)
    ## pretty-print exception
    _write _view(msg.message, label)
    msg.backtrace.to_a.slice(0..5).each do |frame| _write _view(frame, label) end
  end

  def self._write(line)
    if Script.current.vars.include?("--headless") or not defined?(:_respond)
      $stdout.write(line + "\n")
    elsif line.include?("<") and line.include?(">")
      respond(line)
    else
      _respond Preset.as(:debug, CGI.escapeHTML(line))
    end
  end

  def self._view(msg, label)
    label = [Script.current.name, label].flatten.compact.join(".")
    safe = msg.inspect
    #safe = safe.gsub("<", "&lt;").gsub(">", "&gt;") if safe.include?("<") and safe.include?(">")
    "[#{label}] #{safe}"
  end

  def self.pp(msg, label = :debug)
    respond _view(msg, label)
  end

  def self.dump(*args)
    pp(*args)
  end
end