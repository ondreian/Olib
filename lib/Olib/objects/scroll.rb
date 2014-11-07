class Scroll < Item_Wrapper
  attr_accessor :spells, :worthy, :whitelist
  class << self
    attr_accessor :custom
  end

  def initialize(item)
    super item
    @whitelist = [ 
                    101, 102, 103, 107, 116, 120, 
                    202, 211, 208, 215, 219, 
                    303, 307, 310, 313, 315,
                    401, 406, 414, 425, 430, 
                    503, 507, 508, 509, 511, 513, 520, 
                    601, 602, 606, 613, 617, 618, 625, 640, 
                    712, 
                    905, 911, 913, 920, 
                    1109, 1119, 1125, 1130,
                    1201, 1204,
                    1601, 1603, 1606, 1610, 1611, 1612, 1616,
                    1712, 1718
                  ]
    @spells = []
    return self
  end

  def worthy?
    @worthy = false
    read unless @spells.length > 0
    list = Scroll_O.custom ? Scroll_O.custom : @whitelist
    @spells.each do |spell| @worthy = true if list.include? spell[:n].to_i end
    @worthy
  end

  def sell
    unless self.worthy?
      result = dothistimeout "get ##{@id}", 1, /^You remove/
      fput "sell ##{@id}" if result
    end
  end

  def read
    Library.do "read ##{@id}", /It takes you a moment to focus/
    result = matchtimeout(Library.timeout, 'On the')
    if result
      begin
        Timeout::timeout(0.1) do
          while(get =~ /\(([0-9]+)\) ([a-zA-Z'\s]+)/)
            spell        = {} 
            spell[:n]    = $1.to_i
            spell[:name] = $2.to_s
            @spells.push spell
          end 
        end
      rescue Timeout::Error
        # Silent
      end
    end
    self
  end

end