module Olib

  class Gemstone_Regex
    def Gemstone_Regex.item
      re = {}
      re[:heirloom] = /are the initials ([A-Z]{2})./
      re[:give]     = /Excellent.  I'm sure the person who lost this will be quite happy/
      re
    end

    def Gemstone_Regex.common_lines
      /^\w+ gestures while calling upon the lesser spirits for aid\.\.\.$|^\w+ traces a sign while petitioning the spirits for cognition\.\.\.$|^\w+ utters a light chant and raises (his|her) hands\, beckoning the lesser spirits to (his|her) aid\.\.\.$|^\w+ traces a sign while beseeching the spirits for empowerment\.\.\.$|^\w+ murmurs a simple\, mystical chant\.\.\.$|^\w+ appears to be focusing (his|her) thoughts while chanting softly\.\.\.$|^\w+ gestures while summoning the spirits of nature to (his|her) aid\.\.\.$|^\w+ makes a nearly imperceptible motion while whispering a soft phrase\.\.\.$|^\w+ makes a quick gesture while calling upon the powers of the elements\.\.\.$|^\w+ traces a simple rune while intoning a short, mystical phrase\.\.\.$|^\w+ intones a phrase of elemental power while raising (his|her) hands\.\.\.$|^\w+ recites a series of mystical phrases while raising (his|her) hands\.\.\.$|^\w+\'\w+ hands glow with power as s?he summons elemental energy to (his|her) command\.\.\.$|^\w+ traces a series of glowing runes while chanting an arcane phrase\.\.\.$|^\w+ begins a musical chant\.\.\.$|^\w+ traces a sign that contorts in the air while s?he forcefully incants a dark invocation\.\.\.$|^\w+ begins drawing a faint\, twisting symbol as s?he utters an arcane invocation in hushed tones\.\.\.$|^A light blue glow surrounds \w+\.$|^The air thickens and begins to swirl around \w+\.$|^\w+ suddenly looks more powerful\.$|^\w+\'\w+ body seems to glow with an internal strength\.$|^\w+\'\w+ veins stand out briefly\.$|^A deep blue glow surrounds \w+\.$|^\w+\'\w+ eyes narrow in concentration\.$|^An aura of resolve suddenly fills \w+\'s expression\.$|^A misty halo surrounds \w+\.$|^Dark red droplets coalesce upon \w+\'s skin.  The sanguine liquid is visible for only an instant before it sinks into (his|her) flesh\.$|^\w+ gets an intense expression on (his|her) face\.$|^A dull golden nimbus surrounds \w+\.$|^\w+ is surrounded by a white light\.$|^A dim aura surrounds \w+\.$|^\w+ begins to breathe more deeply\.$|^A faint slick sheen makes the air about \w+ visible\, then sinks into him and disappears\.$|^\w+ stands tall and appears more confident\.$|^A brilliant aura surrounds \w+\.$|^An opalescent aura surrounds \w+\.$|^\w+ begins to sing of heroic deeds and appears to be bolstered\.$|^As \w+ sings\, the air sparkles briefly around him\.$|^\w+ sings of Kai\'s many triumphs\, lifting (his|her) spirits\.$|^\w+ begins singing and focuses (his|her) voice into a vortex of air centered on (his|her) left arm\.$|^\w+ begins to sing of valiant legends and appears to be more protected\.$|^\w+ begins singing and focuses (his|her) voice into a vortex of air shaped like a sonic .*\, centered on (his|her) right hand\.$|^\w+ begins singing and focuses (his|her) voice into a vortex of air centered around (his|her) body\.$|^As \w+ sings\, you sense the mana around him begin to swirl and move with a subtle grace\.$|^\w+ begins to sing a sibilant melody\.  Suddenly\, mirror images of \w+ appear in the area\, making it difficult to tell which is real and which are the illusions\.$|^As \w+ sings\, a squall of wind briefly swirls about him\.$|^\w+ appears to be keenly aware of (his|her) surroundings\.$|^A scintillating light surrounds \w+\'s hands\.$|^\w+ becomes calm and focused\.$|^A (silvery|bright|brilliant) luminescence surrounds \w+\.$|^\w+ stands taller\, as if bolstered with a sense of confidence\.$|^(His|Her) body is surrounded by a dim dancing aura\.$|^\w+ appears somewhat more powerful\.$|^\w+ begins moving faster than you thought possible\.$|^\w+ appears considerably more powerful\.$|^\w+ suddenly disappears\.$|^A translucent sphere forms around \w+\.$|^Glowing specks of light red energy begin to spin around \w+\.$|^\w+ is surrounded by a shimmering field of energy\.$|^\w+ appears somehow changed\.$|^\w+ looks considerably more imposing\.$|^\w+ bristles with energy\.$|^A layer of hard\, shifting stone forms around \w+\.$|^\w+ looks more aware of the surroundings\.$|^\w+ looks more nimble\.$|^Gold\-traced pale green ribbons of energy swirl about and coalesce upon \w+\.$|^\w+ seems to blend into the surroundings better\.$|^The air about \w+ shimmers slightly\.$|^\w+ appears to be listening intently to something\.$|^(His|Her) eyes begin to shine with an inner strength\.$|^\w+ is surrounded by an aura of natural confidence\.$|^\w+ begins to move with cat\-like grace\.$|^\w+ suddenly looks much more dextrous\.$|^\w+ looks charged with power\.$|^\w+ is surrounded by a writhing barrier of sharp thorns\.$|^A dense fog gathers around \w+\, but soon fills the room\.$|^An invisible force guides \w+\.$|^A wall of force surrounds \w+.$|^A shadowy patch of ether rises up through the floor to encompass \w+\, swiftly sinking into (his|her) skin\.$|^(Novice |Apprentice |Journeyman |Lord |Great Lord |High Lord |Grand Lord |Lady |Great Lady |High Lady |Grand Lady |Maiden |Chronicler |Mistress )?[a-zA-Z]+ (just went through|just came through|just|strides|begins to walk|just stumbled) (entered|came trudging |trudged away moving |strode |away moving |came crawling |skipped merrily |came sashaying |gracefully sashayed |came marching |went |crawled |limped |marched off to the )?(a half\-timbered pale grey stone guildhall|climbed a spiral staircase|a wooden hatch|a dark opening|arrived\, skipping merrily|north|northeast|east|southeast|south|southwest|west|northwest|out|up|down|in\,?|in gracefully|through an archway|arrived)( but suddenly trips and goes flailing out of sight| flailing (his|her) arms wildly while trying to right (himself|herself))?(\!|\.)$|You feel less drained|You feel at full magical power again|You gesture|Your spell is ready|just bit the dust|joins the adventure|just arrived|returns home from a hard day of adventuring|no longer effective|You sense that your attunement|You do not feel drained anymore|You feel the magic of your spell depart|just arrived|just climbed up|^Your SIGN OF ([A-Z]+) is no longer effective.$/
    end

    def Gemstone_Regex.targetable
      re = {}
      re[:yes] = /^You are now targeting/
      re[:no]  = /^You can't target/
      re
    end
    def Gemstone_Regex.bounty
      re = {}
      re[:herb]             = /requires (?:a|an|some) ([a-zA-Z '-]+) found (?:in|on|around) ([a-zA-Z '-]+).  These samples must be in pristine condition.  You have been tasked to retrieve ([0-9]+)/
      re[:escort]           = /Go to the (.*?) and WAIT for (?:him|her|them) to meet you there.  You must guarantee (?:his|her|their) safety to ([a-zA-Z '-]+) as soon as/
      re[:gem]              = /has received orders from multiple customers requesting (?:a|an|some) ([a-zA-Z '-]+).  You have been tasked to retrieve ([0-9]+)/
      re[:heirloom]         = /You have been tasked to recover ([a-zA-Z '-]+) that an unfortunate citizen lost after being attacked by (a|an|some) ([a-zA-Z '-]+) (in|on|around|near|by) ([a-zA-Z '-]+)./
      re[:heirloom_found]   = /^You have located the heirloom and should bring it back to/
      re[:turn_in]          = /You have succeeded in your task and can return to the Adventurer's Guild to receive your reward/
      re[:guard_turn_in]    = /^You succeeded in your task and should report back to/
      re[:guard_bounty]     = /Go report to ([a-zA-Z ]+) to find out more/
      re[:cull]             = /^You have been tasked to suppress (^((?!bandit).)*$) activity (?:in|on) (?:the )? (.*?)(?: near| between| under|\.) ([a-zA-Z' ]+).  You need to kill ([0-9]+)/
      re[:bandits]          = /^You have been tasked to suppress bandit activity (?:in |on )(?:the )(.*?)(?: near| between| under) ([a-zA-Z' ]+).  You need to kill ([0-9]+)/
      re[:dangerous]        = /You have been tasked to hunt down and kill a particularly dangerous (.*) that has established a territory (?:in|on) (?:the )?(.*?)(?: near| between| under|\.)/
      re[:get_skin_bounty]  = /The local furrier/
      re[:get_herb_bounty]  = /local herbalist|local healer|local alchemist/
      re[:get_gem_bounty]   = /The local gem dealer, ([a-zA-Z ]+), has an order to fill and wants our help/
      re[:creature_problem] = /It appears they have a creature problem they\'d like you to solve/
      re[:rescue]           = /A local divinist has had visions of the child fleeing from (?:a|an) (.*) (?:in|on) (?:the )?(.*?)(?: near| between| under|\.)/

      re[:failed_bounty]    = /You have failed in your task/
      re[:get_bounty]       = /You are not currently assigned a task/
     
    end
    def Gemstone_Regex.bandit_traps
      re = {}
      re[:net]     = /Suddenly, a carefully concealed net springs up from the ground, completely entangling you/
      re[:jaws]    = /large pair of carefully concealed metal jaws slam shut on your/
      re[:wire]    = /stumbled right into a length of nearly invisible razor wire/
      re[:pouch]   = /of air as you realize you've just stepped on a carefully concealed inflated pouch/
      re[:rope]    = /wrapping around your ankle and tossing you up into the air/
      re[:spikes]  = /from under you as you fall into a shallow pit filled with tiny spikes/
      re[:net]     = /completely entangling you/
      re[:net_end] = /The net entangling you rips and falls apart/
      re[:hidden]  = /You hear a voice shout|leaps|flies from the shadows toward you/
      re[:fail]    = /You spy/
      re[:statue]  = /A faint silvery light flickers from the shadows/
      re
    end
    def Gemstone_Regex.escortees
      /^(?:traveller|magistrate|merchant|scribe|dignitary|official)$/
    end
    def Gemstone_Regex.bandits
      /thief|rogue|bandit|mugger|outlaw|highwayman|marauder|brigand|thug|robber/
    end
    def Gemstone_Regex.undead
      /zombie rolton|lesser ghoul|skeleton|lesser frost shade|lesser shade|phantom|moaning phantom|ghost|ice skeleton|greater ghoul|revenant|mist wraith|dark apparition|lesser mummy|firephantom|spectral fisherman|bone golem|snow spectre|death dirge|werebear|darkwoode|spectre|shadowy spectre|wraith|tomb wight|wolfshade|ghoul master|ghost wolf|ghostly warrior|dark assassin|rotting krolvin pirate|elder ghoul master|nedum vereri|arch wight|wood wight|ancient ghoul master|nonomino|zombie|crazed zombie|rotting woodsman|roa'ter wormling|carceris|spectral monk|tree spirit|monastic lich|skeletal lord|moaning spirit|elder tree spirit|krynch|skeletal ice troll|rotting corpse|rotting farmhand|ghostly mara|ghostly pooka|skeletal giant|rock troll zombie|skeletal soldier|spectral warrior|troll wraith|spectral shade|barghest|spectral woodsman|spectral lord|skeletal warhorse|lesser moor wight|shadow mare|shadow steed|vourkha|greater moor wight|forest bendith|spectral miner|bog wraith|phantasma|frozen corpse|baesrukha|night mare|gaunt spectral servant|bog wight|ice wraith|lesser vruul|rotting chimera|dybbuk|necrotic snake|waern|banshee|flesh golem|seeker|ethereal mage apprentice|nightmare steed|eidolon|decaying Citadel guardsman|rotting Citadel arbalester|putrefied Citadel herald|phantasmal bestial swordsman|wind wraith|soul golem|greater vruul|naisirc|shrickhen|seraceris|lich qyn'arj|n'ecare|lost soul|vaespilon|spectral triton defender|ethereal triton sentry/
    end
    def Gemstone_Regex.antimagic
      /lesser construct|Vvrael warlock|Vvrael witch/
    end
    def Gemstone_Regex.living
      /carrion worm|black rolton|black-winged daggerbeak|fanged rodent|kobold|mountain rolton|giant rat|slimy little grub|young grass snake|fire ant|rolton|spotted gnarp|giant ant|cave gnome|rabid squirrel|big ugly kobold|goblin|pale crab|fanged goblin|brown gak|thyril|spotted gak|sea nymph|Mistydeep siren|dark vysan|greater ice spider|fire salamander|cave nipper|kobold shepherd|relnak|striped relnak|cave gnoll|hobgoblin|Bresnahanini rolton|velnalin|spotted velnalin|striped gak|white vysan|mountain snowcat|troglodyte|black urgh|water moccasin|cobra|urgh|ridge orc|whiptail|spotted leaper|fanged viper|mongrel kobold|night golem|mongrel hobgoblin|bobcat|coyote|water witch|nasty little gremlin|monkey|spotted lynx|cockatrice|leaper|lesser orc|snowy cockatrice|blood eagle|lesser red orc|hobgoblin shaman|shelfae soldier|lesser burrow orc|greater kappa|greater spider|thrak|crystal crab|greater orc|greater burrow orc|albino tomb spider|mottled thrak|brown spinner|crocodile|manticore|rabid guard dog|great boar|raider orc|cave worm|gnoll worker|giant marmot|shelfae chieftain|Neartofar orc|wall guardian|crystal golem|dark orc|great stag|plumed cockatrice|tawny brindlecat|gnoll thief|deranged sentry|Agresh troll scout|forest troll|grey orc|silverback orc|great brown bear|brown boar|giant weasel|black boar|swamp troll|panther|ridgeback boar|luminescent arachnid|gnoll ranger|large ogre|puma|arctic puma|Neartofar troll|black leopard|humpbacked puma|black bear|Agresh troll warrior|mongrel wolfhound|plains orc warrior|cave troll|phosphorescent worm|hill troll|wind witch|fire guardian|mountain ogre|Agresh bear|mongrel troll|red bear|fire rat|banded rattlesnake|mountain troll|spiked cavern urchin|gnoll guard|giant veaba|plains ogre|forest ogre|mountain goat|black panther|dark shambler|plains orc scout|krolvin mercenary|cave lizard|war troll|fire cat|mountain lion|bighorn sheep|shelfae warlord|plains orc shaman|greenwing hornet|plains lion|thunder troll|krolvin warrior|steel golem|gnoll priest|ogre warrior|massive grahnk|major spider|Agresh troll chieftain|striped warcat|Arachne servant|cave bear|plains orc chieftain|cougar|warthog|crested basilisk|dark panther|centaur|fenghai|Arachne acolyte|tree viper|burly reiver|reiver|ice hound|wolverine|veteran reiver|arctic wolverine|giant albino scorpion|krolvin warfarer|gnoll jarl|jungle troll|Arachne priest|Arachne priestess|troll chieftain|cyclops|Grutik savage|lesser stone gargoyle|snow leopard|giant hawk-owl|fire ogre|dobrem|ki-lin|darken|pra'eda|Grutik shaman|ice troll|arctic manticore|scaly burgee|hooded figure|hisskra warrior|giant albino tomb spider|hunter troll|jungle troll chieftain|mammoth arachnid|ash hag|wild hound|caribou|wild dog|giant fog beetle|mezic|three-toed tegu|hisskra shaman|maw spore|moor hound|sand beetle|tundra giant|colossus vulture|hisskra chieftain|moor witch|cold guardian|lava troll|moor eagle|bog troll|shimmering fungus|water wyrd|snow crone|undertaker bat|dust beetle|krolvin slaver|fire giant|arctic titan|Sheruvian initiate|tusked ursian|huge mein golem|magru|mud wasp|grizzly bear|frost giant|wood sprite|krolvin corsair|vesperti|greater bog troll|stone gargoyle|storm giant|myklian|kiramon worker|lesser ice giant|Sheruvian monk|roa'ter|siren lizard|shan wizard|shan warrior|minor glacei|dark vortece|shan cleric|swamp hag|shan ranger|wasp nest|dreadnought raptor|forest trali shaman|firethorn shoot|polar bear|mastodonic leopard|lesser faeroth|kiramon defender|forest trali|cinder wasp|greater ice giant|major glacei|bog spectre|sand devil|warrior shade|horned vor'taz|red-scaled thrak|greater faeroth|snow madrinol|tomb troll|wooly mammoth|ice golem|lesser ice elemental|sabre-tooth tiger|stone sentinel|animated slush|skayl|tomb troll necromancer|stone troll|glacial morph|lava golem|stone giant|massive pyrothag|black forest viper|massive black boar|fire elemental|black forest ogre|stone mastiff|Illoke mystic|massive troll king|ice elemental|Sheruvian harbinger|grifflet|fire sprite|emaciated hierophant|red tsark|Illoke shaman|muscular supplicant|yeti|lesser griffin|hunch-backed dogmatist|krag yeti|fire mage|krag dweller|storm griffin|lesser minotaur|moulis|csetairi|minotaur warrior|farlook|raving lunatic|minotaur magus|dhu goleras|earth elemental|gnarled being|caedera|greater krynch|gremlock|Illoke elder|festering taint|aivren|greater earth elemental|Ithzir scout|Illoke jarl|Ithzir initiate|water elemental|Ithzir janissary|Ithzir herald|triton dissembler|greater construct|Ithzir adept|triton executioner|siren|Ithzir seer|triton combatant|triton radical|war griffin|triton magus|greater water elemental/
    end
    def Gemstone_Regex.shop
      db = {}
      db[:success]            = /^You hand over|You place your/
      db[:failure]            = {}
      db[:failure][:missing]  = /^There is nobody here to buy anything from/
      db[:failure][:silvers]  = /^The merchant frowns and says/
      db[:failure][:full]     = /^There's no more room for anything else/
      db[:failure][:own]      = /^Buy your own merchandise?/
      db
    end
    def Gemstone_Regex.gems
      re                         = {}
      # Expressions to match interaction with gems
      re[:appraise]              = {}
      re[:appraise][:gemshop]    = /inspects it carefully before saying, "I'll give you ([0-9]+) for it if you want to sell/
      re[:appraise][:player]     = /You estimate that the ([a-zA-Z '-]+) is of ([a-zA-Z '-]+) quality and worth approximately ([0-9]+) silvers/
      re[:appraise][:failure]    = /As best you can tell, the ([a-zA-Z '-]+) is of average quality/
      re[:singularize]           = proc{ |str| str.gsub(/ies$/, 'y').gsub(/zes$/,'z').gsub(/s$/,'').gsub(/large |medium |containing |small |tiny |some /, '').strip }
      re
    end
    def Gemstone_Regex.get
      re = {}
      re[:failure] = {}
      # Expressions to match `get` verb results
      re[:failure][:weight]       = /You are unable to handle the additional load/
      re[:failure][:hands_full]   = /^You need a free hand to pick that up/
      re[:failure][:ne]           = /^Get what/
      re[:failure][:buy]          = /^A sales clerk rushes/
      re[:failure][:pshop]        = /^Looking closely/
      re[:success]                = /^You pick up|^You remove|^You rummage|^You draw|^You grab|^You reach|^You already/
      re
    end
    def Gemstone_Regex.put
      re = {}
      re[:failure]        = {}    
      re[:failure][:full] = /^won't fit in the/
      re[:failure][:ne]   = /^I could not find what you were referring to/
      re[:success]        = /^You put a|^You tuck|^You sheathe|^You slip|^You roll up|^You tuck/
      re
    end
    def Gemstone_Regex.jar(name=nil)
      if name
        return name.gsub(/large |medium |containing |small |tiny |some /, '').sub 'rubies', 'ruby'
      else
        return false
      end
    end
  end
end