class Disk
  attr_accessor :owner, :full

  def initialize(owner)
    @owner = owner
    @full  = false
    GameObj.loot.find do |item|
      item.name.downcase =~/#{owner.downcase}/
    end
  end

  def add(item)

  end

  def full?
    @full
  end
end