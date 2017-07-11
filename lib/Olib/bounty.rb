require "ostruct"

class Bounty
  NPCS = /guard|sergeant|Felinium|clerk|purser|taskmaster|gemcutter|jeweler|akrash|kris|Ghaerdish|Furryback|healer|dealer|Ragnoz|Maraene|Kelph|Areacne|Jhiseth|Gaedrein/i
  HERBALIST_AREAS = /illistim|vaalor|legendary rest|solhaven/i
  @@listeners = {}
  # this should be refactored to use CONST
  REGEX = OpenStruct.new(
    creature_problem: /It appears they have a creature problem they\'d like you to solve/,
    report_to_guard:  /^You succeeded in your task and should report back to/,
    get_skin_bounty:  /The local furrier/,
    heirloom_found:   /^You have located the heirloom and should bring it back to/,
    cooldown:         /^You are not currently assigned a task.  You will be eligible for new task assignment in about (?<minutes>.*?) minute(s)./,
    
    dangerous: /You have been tasked to hunt down and kill a particularly dangerous (?<creature>.*) that has established a territory (?:in|on) (?:the )?(?<area>.*?)(?: near| between| under|\.)/,
    succeeded: /^You have succeeded in your task and can return to the Adventurer's/,
    heirloom:  /^You have been tasked to recover (a|an|some) (?<heirloom>.*?) that an unfortunate citizen lost after being attacked by (a|an|some) (?<creature>.*?) (?:in|on|around|near|by) (?<area>.*?)(| near (?<realm>.*?))\./,


    get_rescue:      /It appears that a local resident urgently needs our help in some matter/,
    get_bandits:     /It appears they have a bandit problem they'd like you to solve./,
    get_heirloom:    /It appears they need your help in tracking down some kind of lost heirloom/,
    get_herb_bounty: /local herbalist|local healer|local alchemist/,
    get_gem_bounty:  /The local gem dealer, (?<npc>[a-zA-Z ]+), has an order to fill and wants our help/,

    herb:   /requires (?:a |an |)(?<herb>.*?) found (?:in|on|around|near) (?<area>.*?)(| (near|between) (?<realm>.*?)).  These samples must be in pristine condition.  You have been tasked to retrieve (?<number>[\d]+)/,
    escort: /Go to the (.*?) and WAIT for (?:him|her|them) to meet you there.  You must guarantee (?:his|her|their) safety to (?<destination>.*?) as soon as/,
    gem:    /has received orders from multiple customers requesting (?:a|an|some) (?<gem>[a-zA-Z '-]+).  You have been tasked to retrieve (?<number>[0-9]+)/,

    cull:    /^You have been tasked to suppress (?<creature>(?!bandit).*) activity (?:in|on|around) (?<area>.*?)(| (near|between) (?<realm>.*?)).  You need to kill (?<number>[0-9]+)/,
    bandits: /^You have been tasked to suppress bandit activity (?:in|on|around) (?<area>.*?) (?:near|between|under) (?<realm>.*?).  You need to kill (?<number>[0-9]+)/,

    rescue:  /A local divinist has had visions of the child fleeing from (?:a|an) (?<creature>.*) (?:in|on) (?:the )?(?<area>.*?)(?: near| between| under|\.)/,
    failed:  /You have failed in your task/,
    none:    /You are not currently assigned a task/,
    skin:    /^You have been tasked to retrieve (?<number>\d+) (?<skin>.*?) of at least (?<quality>.*?) quality for (?<buyer>.*?) in (?<realm>.*?)\.\s+You can SKIN them off the corpse of (a|an|some) (?<creature>.*?) or/,
    
    help_bandits: /You have been tasked to help (?<partner>.*?) suppress bandit activity (in|on|around) (?<area>.*?)(| near (?<realm>.*?)).  You need to kill (?<number>[0-9]+)/
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
      raise Exception.new "could not match Bounty: #{str}\nplease notify Ondreian"
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

  def Bounty.ask_for_bounty
    if invisible?
      fput "unhide"
    end

    if hidden?
      fput "unhide"
    end

    if Bounty.npc
      fput "ask ##{Bounty.npc.id} for bounty"
      Bounty
    else
      raise Exception.new "could not find Bounty.npc here"
    end
    # give the XML parser time to update
    sleep 0.2
  end

  def Bounty.herbalist
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

  def Bounty.on(namespace, &block)
    @@listeners[namespace] = block
    Bounty
  end

  def Bounty.listeners
    @@listeners
  end

  def Bounty.cooldown?
    Spell[9003].active?
  end

  def Bounty.cooldown!
    if Bounty.cooldown?
      Go2.origin
      wait_until { !Bounty.cooldown? }
    end
    Bounty
  end

  def Bounty.throw_missing_listener
    msg = "\n"
    msg.concat "\nBounty.dispatch called for `:#{Bounty.type}` without a defined listener\n\n"
    msg.concat "define a listener with:\n"
    msg.concat " \n" 
    msg.concat "   Bounty.on(:#{Bounty.type}) {\n" 
    msg.concat "      # do something\n"
    msg.concat "   }\n"
    msg.concat " \n"
    msg.concat "or rescue this error (Olib::Errors::Fatal) gracefully\n"
    msg.concat " \n"
    raise Olib::Errors::Fatal.new msg
  end

  def Bounty.dispatch(listener=nil)
    if listener
      if @@listeners[listener]
        @@listeners[listener].call
        return Bounty
      else 
        Bounty.throw_missing_listener
      end
    end

    if @@listeners[Bounty.type]
      @@listeners[Bounty.type].call
      return Bounty
    else
      Bounty.throw_missing_listener
    end
  end

  def Bounty.find_guard
    Go2.advguard
    if Bounty.npc.nil? then Go2.advguard2 end
    if Bounty.npc.nil? then 
      throw Olib::Errors::Fatal.new "could not find guard"
    end
    return Bounty
  end

  def Bounty.npc
    GameObj.npcs.find { |npc| npc.name =~ NPCS } ||
    GameObj.room_desc.find { |npc| npc.name =~ NPCS }
  end
end