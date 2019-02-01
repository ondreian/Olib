class String
  def is_i?
    !!(self =~ /\A[-+]?[0-9]+\z/)
  end

  def methodize
    self.downcase.strip.gsub(/-|\s+|'|"/, "_").to_sym
  end
end
