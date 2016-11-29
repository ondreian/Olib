class Area < Olib::Container
  def self.contents
    GameObj.loot.map { |obj| Olib::Item.new(obj) }
  end

  def each
    self.contents.each { |item|
      yield item
    }
  end

  class << self
    Olib::Item.type_methods.each { |method, tag|
      exp = /#{tag}/
      define_method(method.to_sym) do
        GameObj.loot
          .select { |obj| obj.type =~ exp }
          .map { |obj| Olib::Item.new(obj) }
      end
    }
  end

  def Area.deep
    Area.new
  end

  attr_accessor :room, :objects

  def initialize
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
        unless container.nested?
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