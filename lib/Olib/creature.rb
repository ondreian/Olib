# enables creature specific logic
# TODO
# - add flying types
# - add corporeal types
# - add quadrapedal types
# - add known spells/cmans/manuevers and algorithm for danger level by profession and skills
 
require 'Olib/extender'
require 'Olib/dictionary'
 
module Olib
  class Creature < Gameobj_Extender
    def Creature.escortee(name)
      name =~ /^(?:traveller|magistrate|merchant|scribe|dignitary|official)$/
    end

    def Creature.bandit(name)
      name =~ /thief|rogue|bandit|mugger|outlaw|highwayman|marauder|brigand|thug|robber/
    end
    
    def Creature.undead(name)
      name =~ /zombie rolton|lesser ghoul|skeleton|lesser frost shade|lesser shade|phantom|moaning phantom|ghost|ice skeleton|greater ghoul|revenant|mist wraith|dark apparition|lesser mummy|firephantom|spectral fisherman|bone golem|snow spectre|death dirge|werebear|darkwoode|spectre|shadowy spectre|wraith|tomb wight|wolfshade|ghoul master|ghost wolf|ghostly warrior|dark assassin|rotting krolvin pirate|elder ghoul master|nedum vereri|arch wight|wood wight|ancient ghoul master|nonomino|zombie|crazed zombie|rotting woodsman|roa'ter wormling|carceris|spectral monk|tree spirit|monastic lich|skeletal lord|moaning spirit|elder tree spirit|krynch|skeletal ice troll|rotting corpse|rotting farmhand|ghostly mara|ghostly pooka|skeletal giant|rock troll zombie|skeletal soldier|spectral warrior|troll wraith|spectral shade|barghest|spectral woodsman|spectral lord|skeletal warhorse|lesser moor wight|shadow mare|shadow steed|vourkha|greater moor wight|forest bendith|spectral miner|bog wraith|phantasma|frozen corpse|baesrukha|night mare|gaunt spectral servant|bog wight|ice wraith|lesser vruul|rotting chimera|dybbuk|necrotic snake|waern|banshee|flesh golem|seeker|ethereal mage apprentice|nightmare steed|eidolon|decaying Citadel guardsman|rotting Citadel arbalester|putrefied Citadel herald|phantasmal bestial swordsman|wind wraith|soul golem|greater vruul|naisirc|shrickhen|seraceris|lich qyn'arj|n'ecare|lost soul|vaespilon|spectral triton defender|ethereal triton sentry/
    end
    
    def Creature.antimagic(name)
      name =~ /lesser construct|Vvrael warlock|Vvrael witch/
    end
    
    def Creature.living(name)
      name =~ /carrion worm|black rolton|black-winged daggerbeak|fanged rodent|kobold|mountain rolton|giant rat|slimy little grub|young grass snake|fire ant|rolton|spotted gnarp|giant ant|cave gnome|rabid squirrel|big ugly kobold|goblin|pale crab|fanged goblin|brown gak|thyril|spotted gak|sea nymph|Mistydeep siren|dark vysan|greater ice spider|fire salamander|cave nipper|kobold shepherd|relnak|striped relnak|cave gnoll|hobgoblin|Bresnahanini rolton|velnalin|spotted velnalin|striped gak|white vysan|mountain snowcat|troglodyte|black urgh|water moccasin|cobra|urgh|ridge orc|whiptail|spotted leaper|fanged viper|mongrel kobold|night golem|mongrel hobgoblin|bobcat|coyote|water witch|nasty little gremlin|monkey|spotted lynx|cockatrice|leaper|lesser orc|snowy cockatrice|blood eagle|lesser red orc|hobgoblin shaman|shelfae soldier|lesser burrow orc|greater kappa|greater spider|thrak|crystal crab|greater orc|greater burrow orc|albino tomb spider|mottled thrak|brown spinner|crocodile|manticore|rabid guard dog|great boar|raider orc|cave worm|gnoll worker|giant marmot|shelfae chieftain|Neartofar orc|wall guardian|crystal golem|dark orc|great stag|plumed cockatrice|tawny brindlecat|gnoll thief|deranged sentry|Agresh troll scout|forest troll|grey orc|silverback orc|great brown bear|brown boar|giant weasel|black boar|swamp troll|panther|ridgeback boar|luminescent arachnid|gnoll ranger|large ogre|puma|arctic puma|Neartofar troll|black leopard|humpbacked puma|black bear|Agresh troll warrior|mongrel wolfhound|plains orc warrior|cave troll|phosphorescent worm|hill troll|wind witch|fire guardian|mountain ogre|Agresh bear|mongrel troll|red bear|fire rat|banded rattlesnake|mountain troll|spiked cavern urchin|gnoll guard|giant veaba|plains ogre|forest ogre|mountain goat|black panther|dark shambler|plains orc scout|krolvin mercenary|cave lizard|war troll|fire cat|mountain lion|bighorn sheep|shelfae warlord|plains orc shaman|greenwing hornet|plains lion|thunder troll|krolvin warrior|steel golem|gnoll priest|ogre warrior|massive grahnk|major spider|Agresh troll chieftain|striped warcat|Arachne servant|cave bear|plains orc chieftain|cougar|warthog|crested basilisk|dark panther|centaur|fenghai|Arachne acolyte|tree viper|burly reiver|reiver|ice hound|wolverine|veteran reiver|arctic wolverine|giant albino scorpion|krolvin warfarer|gnoll jarl|jungle troll|Arachne priest|Arachne priestess|troll chieftain|cyclops|Grutik savage|lesser stone gargoyle|snow leopard|giant hawk-owl|fire ogre|dobrem|ki-lin|darken|pra'eda|Grutik shaman|ice troll|arctic manticore|scaly burgee|hooded figure|hisskra warrior|giant albino tomb spider|hunter troll|jungle troll chieftain|mammoth arachnid|ash hag|wild hound|caribou|wild dog|giant fog beetle|mezic|three-toed tegu|hisskra shaman|maw spore|moor hound|sand beetle|tundra giant|colossus vulture|hisskra chieftain|moor witch|cold guardian|lava troll|moor eagle|bog troll|shimmering fungus|water wyrd|snow crone|undertaker bat|dust beetle|krolvin slaver|fire giant|arctic titan|Sheruvian initiate|tusked ursian|huge mein golem|magru|mud wasp|grizzly bear|frost giant|wood sprite|krolvin corsair|vesperti|greater bog troll|stone gargoyle|storm giant|myklian|kiramon worker|lesser ice giant|Sheruvian monk|roa'ter|siren lizard|shan wizard|shan warrior|minor glacei|dark vortece|shan cleric|swamp hag|shan ranger|wasp nest|dreadnought raptor|forest trali shaman|firethorn shoot|polar bear|mastodonic leopard|lesser faeroth|kiramon defender|forest trali|cinder wasp|greater ice giant|major glacei|bog spectre|sand devil|warrior shade|horned vor'taz|red-scaled thrak|greater faeroth|snow madrinol|tomb troll|wooly mammoth|ice golem|lesser ice elemental|sabre-tooth tiger|stone sentinel|animated slush|skayl|tomb troll necromancer|stone troll|glacial morph|lava golem|stone giant|massive pyrothag|black forest viper|massive black boar|fire elemental|black forest ogre|stone mastiff|Illoke mystic|massive troll king|ice elemental|Sheruvian harbinger|grifflet|fire sprite|emaciated hierophant|red tsark|Illoke shaman|muscular supplicant|yeti|lesser griffin|hunch-backed dogmatist|krag yeti|fire mage|krag dweller|storm griffin|lesser minotaur|moulis|csetairi|minotaur warrior|farlook|raving lunatic|minotaur magus|dhu goleras|earth elemental|gnarled being|caedera|greater krynch|gremlock|Illoke elder|festering taint|aivren|greater earth elemental|Ithzir scout|Illoke jarl|Ithzir initiate|water elemental|Ithzir janissary|Ithzir herald|triton dissembler|greater construct|Ithzir adept|triton executioner|siren|Ithzir seer|triton combatant|triton radical|war griffin|triton magus|greater water elemental/
    end

    def Creature.invasion(name)
      name =~ /taladorian/i
    end

    def Creature.grimswarm(name)
      name =~ /griswarm/i
    end

    def Creature.animate(name)
      name =~ /animated/
    end

    def Creature.ignoreable(name)
      name =~ /kobold|rolton|velnalin|urgh/
    end

    def Creature.self_healing?(name)
      name =~ /troll|csetari/ ? true : false
    end

    def Creature.tag(name)
      Creature.tags.map { |type|
        Creature.send(type, name) ? type : nil
      }.compact
    end

    def Creature.tags
      ['undead', 'living', 'antimagic', 'bandit', 'invasion', 'grimswarm', 'ignoreable', 'escortee', 'animate']
    end

    attr_accessor :wounds, :targetable, :can_cast, :tags, :data, :legged, :limbed
     
    def initialize(creature)
      @wounds               = {}
      @data                 = {}
 
      tag('trollish') if Creature.self_healing?(creature.name)
      @data[:incapacitated] = false
      @data[:tags]          = Creature.tag(creature.name)
       
      heal
      # call the Gameobj_Extender initialize method that copies the game properties to this class
      super(creature)
    end

    def tags
      @data[:tags]
    end

    def tag(tag)
      @data[:tags].push(tag)
    end
 
    def is?(t)
      tags.include?(t)
    end
 
    def bandit?
      tags.include?('bandit')
    end
 
    def grimswarm?
      tags.include('grimswarm')
    end
 
    def heal
      [:right_leg, :left_leg, :right_arm, :left_arm, :head, :neck, :chest, :abdomen, :back, :left_eye, :right_eye, :right_hand, :left_hand, :nerves].each do |location| @wounds[location] = 0 end
      @wounds
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
      if woundinfo =~ /blinded left eye/                              then @wounds[:left_eye]   = 3;  end
      if woundinfo =~ /blinded right eye/                             then @wounds[:right_eye]  = 3;  end
      if woundinfo =~ /severed right (?:hand|paw|claw)/                       then @wounds[:right_hand] = 3;  end
      if woundinfo =~ /severed left (?:hand|paw|claw)/                        then @wounds[:left_hand]  = 3;  end
    if woundinfo =~ /a case of uncontrollable convulsions/                    then @wounds[:nerves]     = 3;  end
      @wounds
    end
     
    def status
      GameObj[@id].status
    end
 
    def trollish?
      @data[:trollish]
    end

    def ignorable?
      is?('ignoreable')
    end
 
    def legged?
      injuries
      trollish? ? false : @wounds[:right_leg] == 3 || @wounds[:left_leg] == 3 || dead? || gone?
    end
 
    def can_cast?
      injuries
      trollish? ? false : @wounds[:right_arm] == 3 || @wounds[:head] == 3 || dead? || gone?
    end
 
    def limbed?
      injuries
      trollish? ? false : @wounds[:right_leg] == 3 || @wounds[:left_leg] == 3 || @wounds[:right_arm] == 3 || dead? || gone?
    end
 
    def dead?
      status =~ /dead/ ? true : false
    end
 
    def active?
      !stunned?
    end
 
    def gone?
      GameObj[@id].nil? ? true : false
    end
 
    def prone?
      status =~ /lying|prone/ ? true : false
    end
 
    def stunned?
      status =~ /stunned/ ? true : false
    end
 
    def kill_shot
      wounds   = injuries
      location = "left eye"
      location = "right eye" if @wounds[:left_eye]  == 3
      location = "head"      if @wounds[:right_eye] == 3
      location = "neck"      if @wounds[:head]      == 3
      location = "back"      if @wounds[:neck]      == 3
      location
    end
 
    def target
      result      = dothistimeout "target ##{@id}", 3, /#{Olib::Dictionary.targetable.values.join('|')}/
      @targetable = result =~ Olib::Dictionary.targetable[:yes] ? true : false
      self
    end
 
    def search
      fput "search ##{@id}" if dead?
    end
 
    def ambush(location=nil)
      until hidden?
        fput "hide"
        waitrt?
      end
      fput "aim #{location}" if location
      fput "ambush ##{@id}"
      waitrt?
      self
    end
 
    def mstrike
      fput "mstrike ##{@id}"
      waitrt?
      self
    end
 
    def kill
      fput "kill ##{@id}"
      waitrt?
      self
    end
 
    def targetable?
      target if @targetable.nil?
      @targetable
    end
 
    def search
      waitrt?
      fput "search ##{id}"
    end
  end
end
