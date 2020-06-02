# enables creature specific logic
# TODO
# - add flying types
# - add corporeal types
# - add quadrapedal types
# - add known spells/cmans/manuevers and algorithm for danger level by profession and skills
require "ostruct"
require "Olib/combat/creatures"
require "Olib/combat/attack"
require "Olib/core/exist"
require "Olib/pattern_matching/rill"

class Creature < Exist
  include Comparable

  Search = Rill.new(
    timeout: 1,
    start:   Rill.union(%(You search the <pushBold/><a exist="{{id}}"),))

  Skin = Rill.new(
    start: Rill.union(%[You skinned the <pushBold/><a exist="{{id}}"],
                      %[You botched],
                      %[has already"]))
  WOUNDS = %i[
    right_leg left_leg right_arm 
    left_arm head neck chest 
    abdomen back left_eye right_eye 
    right_hand left_hand nerves
  ]

  TAGS = OpenStruct.new(
    antimagic: %r[construct|Vvrael],
    lowly:     %r[kobold|rolton|velnalin|urgh],
    trollish:  %r[troll|csetari],
  )

  def self.tags(name)
    TAGS.each_pair.reduce([]) do |is, pair|
      tag, pattern = pair
      name =~ pattern ? is + [tag] : is
    end
  end

  def self.stem_name(foe)
    foe.name.split(" ").slice(1..-1).join(" ")
  end

  def self.add_boss_type(foe)
    return if foe.tags.include?(:aggressive)  
    if GameObj.type_data["aggressive npc"][:name].match stem_name(foe)
      foe.tags << :aggressive
      foe.tags << :npc
    end
  end

  attr_accessor :wounds, :tags
  def initialize(creature)
    super(creature)
    @wounds = {}
    @tags   = Exist.normalize_type_data(creature.type).map(&:to_sym)
    TAGS.each_pair do |tag, pattern| @tags << tag if @name =~ pattern end
    Creature.add_boss_type(self)
    heal
  end

  def tags
    @tags
  end

  def heal
    WOUNDS.each do |location| @wounds[location] = 0 end
    self
  end
   
  def injuries
    fput "look ##{@id}"
    woundinfo = matchtimeout(2, /(he|she|it) (?:has|appears to be in good) .*/i)
    if woundinfo =~ /appears to be in good shape/                         then heal; return @wounds;      end
    if woundinfo =~ /some minor cuts and bruises on (his|her|its) right (?:hind )?leg/      then @wounds[:right_leg]  = 1;  end
    if woundinfo =~ /some minor cuts and bruises on (his|her|its) left (?:hind )?leg/       then @wounds[:left_leg]   = 1;  end
    if woundinfo =~ /some minor cuts and bruises on (his|her|its) (?:right arm|right foreleg)/  then @wounds[:right_arm]  = 1;  end
    if woundinfo =~ /some minor cuts and bruises on (his|her|its) (?:left arm|left foreleg)/    then @wounds[:left_arm]   = 1;  end
    if woundinfo =~ /minor bruises around (his|her|its) neck/                   then @wounds[:neck]       = 1;  end
    if woundinfo =~ /minor bruises around (his|her|its) head/                   then @wounds[:head]       = 1;  end
    if woundinfo =~ /minor cuts and bruises on (his|her|its) chest/               then @wounds[:chest]      = 1;  end
    if woundinfo =~ /minor cuts and bruises on (his|her|its) abdomen/               then @wounds[:abdomen]    = 1;  end
    if woundinfo =~ /minor cuts and bruises on (his|her|its) back/                then @wounds[:back]       = 1;  end
    if woundinfo =~ /bruised left eye/                              then @wounds[:left_eye]   = 1;  end
    if woundinfo =~ /bruised right eye/                             then @wounds[:right_eye]  = 1;  end
    if woundinfo =~ /some minor cuts and bruises on (his|her|its) right (?:hand|paw|claw)/    then @wounds[:right_hand] = 1;  end
    if woundinfo =~ /some minor cuts and bruises on (his|her|its) left (?:hand|paw|claw)/     then @wounds[:left_hand]  = 1;  end
    if woundinfo =~ /a strange case of muscle twitching/                      then @wounds[:nerves]     = 1;  end
    if woundinfo =~ /fractured and bleeding right (?:hind )?leg/                  then @wounds[:right_leg]  = 2;  end
    if woundinfo =~ /fractured and bleeding left (?:hind )?leg/                 then @wounds[:left_leg]   = 2;  end
    if woundinfo =~ /fractured and bleeding (?:right arm|right foreleg)/              then @wounds[:right_arm]  = 2;  end
    if woundinfo =~ /fractured and bleeding (?:left arm|left foreleg)/              then @wounds[:left_arm]   = 2;  end
    if woundinfo =~ /moderate bleeding from (his|her|its) neck/                 then @wounds[:neck]       = 2;  end
    if woundinfo =~ /minor lacerations about (his|her|its) head and a possible mild concussion/ then @wounds[:head]       = 2;  end
    if woundinfo =~ /deep lacerations across (his|her|its) chest/                 then @wounds[:chest]      = 2;  end
    if woundinfo =~ /deep lacerations across (his|her|its) abdomen/               then @wounds[:abdomen]    = 2;  end
    if woundinfo =~ /deep lacerations across (his|her|its) back/                  then @wounds[:back]       = 2;  end
    if woundinfo =~ /swollen left eye/                              then @wounds[:left_eye]   = 2;  end
    if woundinfo =~ /swollen right eye/                             then @wounds[:right_eye]  = 2;  end
    if woundinfo =~ /fractured and bleeding right (?:hand|paw|claw)/                then @wounds[:right_hand] = 2;  end
    if woundinfo =~ /fractured and bleeding left (?:hand|paw|claw)/               then @wounds[:left_hand]  = 2;  end
    if woundinfo =~ /a case of sporadic convulsions/                        then @wounds[:nerves]     = 2;  end
    if woundinfo =~ /severed right (?:hind )?leg/                         then @wounds[:right_leg]  = 3;  end
    if woundinfo =~ /severed left (?:hind )?leg/                          then @wounds[:left_leg]   = 3;  end
    if woundinfo =~ /severed (?:right arm|right foreleg)/                     then @wounds[:right_arm]  = 3;  end
    if woundinfo =~ /severed (?:left arm|left foreleg)/                     then @wounds[:left_arm]   = 3;  end
    if woundinfo =~ /snapped bones and serious bleeding from (his|her|its) neck/          then @wounds[:neck]       = 3;  end
    if woundinfo =~ /severe head trauma and bleeding from (his|her|its) ears/           then @wounds[:head]       = 3;  end
    if woundinfo =~ /deep gashes and serious bleeding from (his|her|its) chest/         then @wounds[:chest]      = 3;  end
    if woundinfo =~ /deep gashes and serious bleeding from (his|her|its) abdomen/         then @wounds[:abdomen]    = 3;  end
    if woundinfo =~ /deep gashes and serious bleeding from (his|her|its) back/          then @wounds[:back]       = 3;  end
    if woundinfo =~ /blinded left eye/                                            then @wounds[:left_eye]   = 3;  end
    if woundinfo =~ /blinded right eye/                                           then @wounds[:right_eye]  = 3;  end
    if woundinfo =~ /severed right (?:hand|paw|claw)/                             then @wounds[:right_hand] = 3;  end
    if woundinfo =~ /severed left (?:hand|paw|claw)/                              then @wounds[:left_hand]  = 3;  end
    if woundinfo =~ /a case of uncontrollable convulsions/                        then @wounds[:nerves]     = 3;  end
    @wounds
  end

  def legged?
    injuries
    @wounds[:right_leg] == 3 || @wounds[:left_leg] == 3
  end

  def can_cast?
    injuries
    @wounds[:right_arm] == 3 || @wounds[:head] == 3
  end

  def alive?
    not dead?
  end

  def limbed?
    injuries
    @wounds[:right_leg] == 3 || @wounds[:left_leg] == 3 || @wounds[:right_arm] == 3
  end

  def prone?
    status.include?(:lying) || status.include?(:prone) ? true : false
  end

  def danger
    status
      .map do |state| Creatures::STATES.index(state) end
      .reduce(&:+) || -1
  end

  def <=>(other)
    self.danger <=> other.danger
  end

  def stunned?
    status.include?(:stunned)
  end

  def skin?
    dead? && !@skinned && metadata.skin.is_a?(String)
  end

  def kill_shot(order = %i(left_eye right_eye head neck back), default = :chest)
    injuries

    return (order
      .drop_while do |area| @wounds[area] == 3 end
      .first || default).to_game
  end

  def targetable?
    target if @targetable.nil?
    @targetable
  end

  def metadata()
    OpenStruct.new Creatures::Metadata.get(name)
  end

  def level()
    metadata.level
  end

  [Creatures::ARCHETYPES, Creatures::STATES].flatten.each do |state|
    define_method((state.to_s + "?").to_sym) do
      [tags, status].flatten.include?(state)
    end
  end

  def target
    result = dothistimeout "target ##{@id}", 3, /#{Dictionary.targetable.values.join('|')}/
    @targetable = (result =~ Dictionary.targetable[:yes])
    self
  end

  def mstrike
    unless dead?
      fput "mstrike ##{@id}"  
    end
    self
  end

  def status()
    super.split(",").map(&:to_sym)
  end

  def dead?
    status.include?(:dead)
  end

  def kill
    Attack.apply(self, :kill)
  end

  def cast
    Attack.apply(self, :cast)
  end

  def fire(location: nil, qstrike: 0)
    Char.aim(location) if location
    Attack.apply(self, :fire)
  end

  def hurl(location: nil, qstrike: 0)
    Char.aim(location) if location
    Attack.apply(self, :hurl, qstrike: qstrike)
  end

  def ambush(location: nil, qstrike: 0)
    Char.aim(location) if location
    Attack.apply(self, :ambush)
  end

  def search()
    waitrt?
    return unless dead?
    (_, _, lines) = Search.capture(self.to_h, %[search \#{{id}}])
    # the first line containers a creature id we want to avoid capturing
    lines[1..-1]
    .map do |line| Exist.scan(line) end
    .flatten.compact.reject(&:gone?)
  end

  def skin()
    waitrt?
    return unless dead?
    (_, _, lines)= Skin.capture(self.to_h, %[skin \#{{id}}])
    @skinned = true
    lines
    .map do |line| Exist.scan(line.split("yielding").last) end
    .flatten.compact.reject(&:gone?)
  end
end

