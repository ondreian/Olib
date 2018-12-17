class Use
  attr_accessor :item
  
  def initialize(item, &block)
    fail Exception, "Use(#{item}) did not have a container" if item.container.nil?
    @item = item
    both(&block) if block
  end

  def run(&block)
    yield @item
    @item.container.add(@item)
  end

  def left(&block)
    empty_left_hand
    @item.take
    Char.swap if Char.right.id == @item.id
    run &block
    fill_left_hand
  end

  def right(&block)
    empty_right_hand
    @item.take
    run &block
    fill_right_hand
  end

  def both(&block)
    empty_hands
    @item.take
    run &block
    fill_hands
  end
end