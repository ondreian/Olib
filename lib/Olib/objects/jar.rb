module Olib
  class Jar < Gameobj_Extender
    attr_accessor :gem, :count, :full, :empty, :pullable, :initial_count, :stacked

    def initialize(item)
      super(item)
      @count = 0 # for empty jars
      @full  = false
      @empty = false
      _extract
      self
    end

    def _extract
      jem = @after_name.gsub('containing', '').strip
      if jem != ''
        @gem = Gemstone_Regex.gems[:singularize].call(jem)
        look_result      = self.look
        if look_result   =~ /^Inside .*? you see ([0-9]+) portion/
          @count         = $1.to_i
          @initial_count = @count
          @full          = look_result.include?('It is full') ? true : false
        else
          respond "[0lib] Oddity detected in extracting Jar data"
        end
      else
        @empty = true
      end
      self
    end

    def shake
      result = Library.do "shake ##{@id}", /^You give your #{@noun} a hard shake|before you realize that it is empty/
      @empty = true if result =~ /realize that it is empty/
      return Gem_O.new(GameObj.left_hand)  if GameObj.right_hand.id == @id
      return Gem_O.new(GameObj.right_hand) if GameObj.left_hand.id == @id
    end

    def full?
      @full
    end

    def empty?
      @empty
    end

    def stash
      take unless GameObj.right_hand.id == @id or GameObj.left_hand == @id
      Library.do "shop sell 1", /^You place your/
    end

    def acquire
      if pullable?
        result    = Library.do "pull ##{@id}", /^You pull/
        @stacked  = true if result =~ /([0-9]+) left/
      else
        result = Library.do "buy ##{@id}", /You hand over/
        unless result =~ /^You hand over/
          Client.end "[FATAL] Logic flaw, not enough coins to acquire #{@name}"
        end
      end
      self
    end

    def look
      Library.do "look in ##{@id}", /^Inside .*? you see [0-9]+ portion|The .*? is empty./
    end

    def pullable?
      unless @pullable
        Library.do "get ##{@id}", /^Looking closely/
        result = Library.timeoutfor "You can PULL", "You'll have to buy it if you want it"
        if result =~ /^You can PULL/ then @pullable = true else @pullable = false end
      end
      @pullable
    end

    def inc
      @count = @count+1
      return self
    end

    def fill
      @full = true
      return self
    end

    def add(g)
      result = Library.do "_drag ##{g.id} ##{@id}", /^You add|^You put|is full|does not appear to be a suitable container for|^You can't do that/
      result = Library.do "put ##{g.id} in my #{@noun}", /^You add|^You put|is full|does not appear to be a suitable container for/ if result =~ /^You can't do that/
      case result
        when /^You add .* filling it/                         then inc.fill
        when /^You add|^You put/                              then inc
        when /does not appear to be a suitable container for/ then return false
        when /is full/                                        then fill; return false
        else                                                       return false
      end
      return true
    end
  end
end