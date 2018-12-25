class Area
  include Enumerable
  def self.method_missing(method, *args, &block)
    if respond_to?(method)
      Area.new.send(method, *args, &block)
    else
      super(method, *args, &block)
    end
  end

  def self.respond_to?(method)
    return super(method) unless Area.new.respond_to?(method)
    return true
  end

  attr_reader :room, :autoid, :objects

  def initialize
    @room     = Room.current
    @auto     = XMLData.room_count
    @objects  = [ GameObj.loot, GameObj.room_desc ].map(&:to_a).flatten.compact.map(&:to_container)
  end

  def each(&block)
    @objects.each(&block)
  end

  def deep
    items = []
    @objects.reject { |container| container.name =~ /[A-Z][a-z]+ disk/ }.each { |container|
        check_container container
        item = Item.new container
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
    items.compact.each do |item| yield(item) end
  end

  def check_container(container)
    unless container.contents
      container.look.at.on
    end
  end
end