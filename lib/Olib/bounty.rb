require "ostruct"

class Bounty
  NPCS = /Bramblefist|balding halfling alchemist|fur trader|guard|sergeant|Brindlestoat|Halfwhistle|tavernkeeper|Luthrek|Felinium|clerk|purser|taskmaster|gemcutter|jeweler|akrash|kris|Ghaerdish|Furryback|healer|dealer|Ragnoz|Maraene|Kelph|Areacne|Jhiseth|Gaedrein/i
  HERBALIST_AREAS = /illistim|vaalor|legendary rest|solhaven/i

  # this should be refactored to use CONST
  REGEX = OpenStruct.new(
    creature_problem: /"Hmm, I've got a task here from (?<town>.*?)\.  It appears they have a creature problem they\'d like you to solve/,
    report_to_guard:  /^You succeeded in your task and should report back to/,
    get_skin_bounty:  /The local furrier/,
    # You have located an antique silver bracer and should bring it back to the sentry just outside town.
    heirloom_found:   Regexp.union(
      /^You have located (?:a|an|some) (?<heirloom>.*?) and should bring it back to/),
    cooldown:         /^You are not currently assigned a task.  You will be eligible for new task assignment in about (?<minutes>.*?) minute(s)./,
    
    dangerous: /You have been tasked to hunt down and kill a particularly dangerous (?<creature>.*) that has established a territory (?:in|on) (?:the )?(?<area>.*?)(?: near| between| under|\.)/,
    succeeded: /^You have succeeded in your task and can return to the Adventurer's/,
    heirloom:  /^You have been tasked to recover (a|an|some) (?<heirloom>.*?) that an unfortunate citizen lost after being attacked by (a|an|some) (?<creature>.*?) (?:in|on|around|near|by) (?<area>.*?)(| near (?<realm>.*?))\./,


    get_rescue:      /"Hmm, I've got a task here from (?<town>.*?)\.  It appears that a local resident urgently needs our help in some matter/,
    get_bandits:     /"Hmm, I've got a task here from (?<town>.*?)\.  It appears they have a bandit problem they'd like you to solve./,
    get_heirloom:    /"Hmm, I've got a task here from (?<town>.*?)\.  It appears they need your help in tracking down some kind of lost heirloom/,
    get_herb_bounty: /local herbalist|local healer|local alchemist|local halfling alchemist/,
    get_gem_bounty:  /"Hmm, I've got a task here from (?<town>.*?)\.  The local gem dealer, (?<npc>[a-zA-Z ]+), has an order to fill and wants our help/,

    herb:   /requires (?:a |an |)(?<herb>.*?) found (?:in|on|around|near) (?<area>.*?)(| (near|between) (?<realm>.*?)).  These samples must be in pristine condition.  You have been tasked to retrieve (?<number>[\d]+)/,
    escort: /Go to the (.*?) and WAIT for (?:him|her|them) to meet you there.  You must guarantee (?:his|her|their) safety to (?<destination>.*?) as soon as/,
    gem:    /The gem dealer in (?<town>.*?), (?<npc>.*?), has received orders from multiple customers requesting (?:a|an|some) (?<gem>[a-zA-Z '-]+).  You have been tasked to retrieve (?<number>[0-9]+)/,
    cull:    /^You have been tasked to suppress (?<creature>(?!bandit).*) activity (?:in|on|around) (?<area>.*?)(| (near|between) (?<realm>.*?)).  You need to kill (?<number>[0-9]+)/,
    bandits: /^You have been tasked to suppress bandit activity (?:in|on|around|near) (?<area>.*?) (?:near|between|under) (?<realm>.*?).  You need to kill (?<number>[0-9]+)/,

    rescue:  /A local divinist has had visions of the child fleeing from (?:a|an) (?<creature>.*) (?:in|on) (?:the )?(?<area>.*?)(?: near| between| under|\.)/,
    failed:  /You have failed in your task/,
    none:    /You are not currently assigned a task/,
    skin:    /^You have been tasked to retrieve (?<number>\d+) (?<skin>.*?) of at least (?<quality>.*?) quality for (?<buyer>.*?) in (?<realm>.*?)\.\s+You can SKIN them off the corpse of (a|an|some) (?<creature>.*?) or/,
    
    help_bandits: /You have been tasked to help (?<partner>.*?) suppress bandit activity (?:in|on|around|near) (?<area>.*?) (?:near|between|under) (?<realm>.*?).  You need to kill (?<number>[0-9]+)/,
    help_creatures: /You have been tasked to help (?<partner>.*?) kill a dangerous creature by suppressing (?<creature>.*) activity (?:in|on|around|near) (?<area>.*?) (?:near|between|under) (?<realm>.*?) during the hunt.  You need to kill (?<number>[0-9]+)/,
    help_cull: /You have been tasked to help (?<partner>.*?) suppress (?<creature>.*) activity (?:in|on|around|near) (?<area>.*?) (?:near|between|under) (?<realm>.*?).  You need to kill (?<number>[0-9]+)/,
  )
  
  # convenience list to get all types of bounties
  def Bounty.types
    REGEX.keys
  end
  ##
  ## @brief      provides an accessor to the raw regular expression dictionary for Bounty logic
  ##
  ## @return     Bounty Regex
  ##
  def Bounty.regex
    REGEX
  end

  def Bounty.singularize(thing)
    thing
      .gsub("teeth", "tooth")
  end

  def Bounty.parse(str)
    type, patt = Bounty.match str
    unless patt
      return OpenStruct.new
    else
      bounty = patt.match(str).to_struct
      bounty[:type] = type
      if bounty[:skin] 
        bounty[:skin] = Bounty.singularize(bounty[:skin]) 
      end

      if bounty[:creature]
        bounty[:tags] = Creature.tags(bounty.creature)
      end

      bounty
    end
  end

  def Bounty.fetch!
    checkbounty.strip
  end

  def Bounty.match(bounty)
    Bounty.regex.each_pair.find do |type, exp|
      exp.match bounty
    end
  end

  def Bounty.method_missing(method)
    str = method.to_s

    if str.chars.last == "?"
      return Bounty.type == str.chars.take(str.length-1).join.to_sym
    end

    unless current[method].nil?
      current[method]
    else
      raise Exception.new "Bounty<#{Bounty.current.to_h}> does not respond to :#{method}"
    end
  end

  def Bounty.type
    match(Bounty.fetch!).first
  end

  def Bounty.task
    Bounty.current
  end

  def Bounty.done?
    succeeded?
  end

  def Bounty.current
    Bounty.parse(checkbounty)
  end

  def self.npc_404!
    raise Exception, "could not find Bounty.npc here" unless Bounty.npc
  end

  # fix because of Dreaven's MA army fucking with XML feed
  def self.find_npc
    return "#%s" % self.npc.id if self.npc
    case XMLData.room_id
    when 15004001
      return "Halline"
    else
      self.npc_404!
    end
  end

  def Bounty.ask_for_bounty(expedite: false)
    fput "unhide" if invisible?
    fput "unhide" if hidden?
    npc = self.find_npc
    previous_state = checkbounty
    if expedite
      fput "ask %s for expedite" % npc
    else
      fput "ask %s for bounty" % npc
    end
    ttl = Time.now + 2
    wait_while {checkbounty.eql?(previous_state) and Time.now < ttl}
  end

  def Bounty.herbalist
    if Room.current.location =~ /hinterwilds/i
      Script.run("go2", "u7503253")
      return self
    end
    if Room.current.location =~ HERBALIST_AREAS
      Go2.herbalist
    else
      Go2.npchealer
    end
    self
  end

  def Bounty.remove
    Go2.advguild
    2.times do fput "ask ##{Bounty.npc.id} for remove" end
    Bounty
  end

  def Bounty.cooldown?
    not XMLData.active_spells["Next Bounty"].nil?
  end

  def Bounty.cooldown!
    if Bounty.cooldown?
      Go2.origin
      wait_while { Bounty.cooldown? }
    end
    Bounty
  end

  def Bounty.find_guard
    Go2.advguard
    if Bounty.npc.nil? then Go2.advguard2 end
    throw Errors::Fatal.new "could not find guard" if Bounty.npc.nil?  
    return Bounty
  end

  def Bounty.npc
    GameObj.npcs.find { |npc| npc.name =~ NPCS } or
    GameObj.room_desc.find { |npc| npc.name =~ NPCS }
  end
end