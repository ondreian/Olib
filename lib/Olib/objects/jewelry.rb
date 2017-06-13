class Jewelry < Olib::Item
  HEIRLOOM = /are the initials ([A-Z]{2})./

  attr_accessor :heirloom
  def heirloom?
    result = Olib.do "look ##{@id}", /^You see nothing unusual/ | HEIRLOOM
    @heirloom = result =~ HEIRLOOM ? true : false
    @heirloom
  end
end