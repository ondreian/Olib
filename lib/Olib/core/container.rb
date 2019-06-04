# for defining containers ala lootsack and using them across scripts
require "Olib/core/exist"
require "Olib/core/item"
require "Olib/core/action"

class GameObj
  def to_container
    Container.new(self)
  end
end

class Container < Exist
  TOPS = %w(table)
  include Enumerable

  def initialize(obj)
    super(obj)
    fput "look in ##{obj.id}" unless GameObj.containers.fetch(id, false)  
  end

  def check_contents
    fput TOPS.include?(noun) ? "look on ##{id}" : "look in ##{id}"  
  end

  def contents
    GameObj.containers.fetch(id, []).map do |item| Item.new(item, self) end
  end

  def closed?
    not GameObj.containers[id]
  end

  def each(&block)
    contents.each(&block)
  end

  def where(**query)
    contents.select(&Where[**query])
  end

  def type(type = nil)
    return super() if type.nil?
    find_by_tags(type)
  end

  def find_by_tags(*tags)
    tags = tags.map(&:to_sym)
    contents.select do |item| (item.tags & tags).size.eql?(tags.size) end
  end

  def rummage
    Rummage.new(self)
  end

  def to_json(*args)
    {id: id, name: name, noun: noun, contents: contents}.to_json(*args)
  end

  def add(*items)
    items.flatten.each do |item|
      Action.try_or_fail(command: "_drag ##{item.id} ##{id}") do
        contents.map(&:id).include?(item.id.to_s)
      end
    end
  end
end