require "ostruct"
require "Olib/ext/string"

class MatchData
  def to_struct
    OpenStruct.new to_h
  end

  def to_h
    Hash[self.names.map(&:to_sym).zip(self.captures.map(&:strip).map do |capture|  
      if capture.is_i? then capture.to_i else capture end
    end)]
  end
end
