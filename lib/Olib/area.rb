class Area < Olib::Container

  def Area.current
    Area.new
  end

  attr_accessor :room, :contents, :objects

  def initialize
    @contents = []
    @room     = Room.current
    @objects  = [ GameObj.loot, GameObj.room_desc ]
      .flatten
      .compact
      .map { |thing| thing.id }
      .uniq # sometimes objects exist in both loot & room_desc
      .map { |id| Olib::Container.new id }
  end

  def contents
    items = []
    @objects
      .reject { |container| container.name =~ /[A-Z][a-z]+ disk/ }
      .each { |container|
        check_container container
        item = Olib::Item.new container
        if (item.tags & TYPES).any?
          items << item
        elsif container.nested?
          container.contents.each { |item|
            item.container = container
            items << item
          }
        else
          container.containers.each do |nested|
            check_container nested
            nested.contents.each { |item|
              item.container = container
              items << item
            }
          end
        end
      }
    items.compact
  end

  def check_container(container)
    unless container.contents
      container.look.at.on
    end
  end


end