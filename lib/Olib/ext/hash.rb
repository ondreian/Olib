require "ostruct"

class Hash
  def to_struct
    OpenStruct.new self
  end
end