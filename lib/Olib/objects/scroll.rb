class Scroll < Item
  @@whitelist = [ 
    101, 102, 103, 107, 116, 120, 
    202, 211, 215, 219,
    303, 307, 310, 313, 315,
    401, 406, 414, 425, 430, 
    503, 507, 508, 509, 511, 513, 520, 
    601, 602, 606, 613, 617, 618, 625, 640, 
    712, 716,
    905, 911, 913, 920, 
    1109, 1119, 1125, 1130,
    1201, 1204,
    1601, 1603, 1606, 1610, 1611, 1612, 1616,
    1712, 1718
  ]
  attr_accessor :spells, :worthy, :whitelist
  
  def Scroll.whitelist
    @@whitelist
  end

  def Scroll.add_to_whitelist(*args)
    @@whitelist + args
  end

  def Scroll.remove_from_whitelist(*args)
    @@whitelist = @@whitelist - args
  end

  def initialize(item)
    super item
    @spells = []
    return self
  end

  def worthy?
    @worthy = false
    read unless @spells.length > 0
    @spells.each do |spell| @worthy = true if Scroll.whitelist.include? spell[:n] end
    @worthy
  end
end
