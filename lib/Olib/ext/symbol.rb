class Symbol
  def to_game
    self.to_s.gsub("_", " ")
  end

  def ok?
    self.eql?(:ok)
  end

  def err?
    self.eql?(:err)
  end
end