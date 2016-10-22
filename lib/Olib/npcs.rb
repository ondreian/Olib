class NPCS
  def self.[](query)
    GameObj.npcs.select { |npc| npc.name =~ /#{query}/ }
  end
end