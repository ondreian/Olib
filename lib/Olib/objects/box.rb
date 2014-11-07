# common interactions with boxes
class Box_O < Item_Wrapper
  attr_accessor :contents, :target, :container
  def open
    # TODO: map results to Gemstone_Regex class & employ a dothistimeout
    fput "open ##{@id}"
  end
  def stash

  end
end