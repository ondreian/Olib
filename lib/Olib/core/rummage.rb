
class Rummage
  SUCCESS = /and remove/
  FAIL    = /but can't seem|^But your hands are full|^You can only rummage for|^What/

  @@message = OpenStruct.new(
    success: SUCCESS,
    fail:    FAIL,
    either:  Regexp.union(SUCCESS, FAIL)
  )

  def self.message
    @@message
  end

  attr_accessor :container

  def initialize(container)
    @container = container
  end

  def perform(mod, query)
    res = Olib.do "rummage ##{@container.id} #{mod} #{query}", Rummage.message.either
    [!res.match(FAIL), res]
  end

  def spell(number)
    perform "spell", number
  end

  def runestone(rune)
    perform "runestone", rune
  end

  def ingredient(str)
    perform "ingredient", str
  end

  def holy(tier)
    perform "holy", tier
  end
end