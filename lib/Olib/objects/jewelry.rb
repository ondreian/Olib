class Jewelry < Olib::Item
  attr_accessor :heirloom
  def heirloom?
    result = Library.do "look ##{@id}", /^You see nothing unusual|#{Gemstone_Regex.item[:heirloom]}/
    @heirloom = result =~ Gemstone_Regex.item[:heirloom] ? true : false
    @heirloom
  end
end