class VBulletin
  attr_accessor :post
  def initialize
    @post = String.new
    self
  end
  def open_bold
    @post.concat "[B]"
    self
  end
  def open_underline
    @post.concat '[U]'
    self
  end
  def close_underline
    @post.concat '[/U]'
    self
  end
  def close_bold
    @post.concat '[/B]'
    self
  end
  def open_color(hexcode)
    @post.concat "[COLOR=\"#{hexcode}\"]"
    self
  end
  def open_table(width=500)
    @post.contat "[TABLE=\"width: #{width}\""
    self
  end
  def close_table
    @post.concat "[/TABLE]"
    self
  end
  def open_tr
    @post.contact "[TR]"
    self
  end
  def close_tr
    @post.contact "[/TR]"
    self
  end
  def open_cell
    @post.concat "[TD]"
    self
  end
  def close_cell
    @post.concat '[/TD]'
    self
  end
  def close_color
    @post.concat '[/COLOR]'
    self
  end
  def add(str)
    @post.concat str
    self
  end
  def add_line(str)
    @post.concat "#{str}\n"
    self
  end
  def open_size(sz)
    @post.concat "[SIZE=#{sz}]"
    self
  end
  def close_size
    @post.concat "[/SIZE]"
    self
  end
  def open_italics
    @post.concat"[I]"
    self
  end
  def close_italics
    @post.concat "[/I]"
    self
  end
  def open_indent
    @post.concat "[INDENT]"
    self
  end
  def close_indent
    @post.concat "[/INDENT]"
    self
  end
  def tab
    @post.concat "\t"
    self
  end
  def enter
    @post.concat "\n"
    self
  end
  def VBulletin.commafy(n)
    n.to_s.chars.to_a.reverse.each_slice(3).map(&:join).join(",").reverse
  end
  def to_s
    @post
  end
end