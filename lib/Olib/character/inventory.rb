module Inventory
  def Inventory.containers
    GameObj.containers
  end

  def Inventory.to_s
    Inventory.items.map(&:to_s)
  end

  def Inventory.[](query)
    GameObj.inv.select { |item|
      item.name == query || item.id == query
    }
  end

  def Inventory.items
    containers.map do |id, contents|
      contents.map(&:to_item)
    end.flatten
  end
end