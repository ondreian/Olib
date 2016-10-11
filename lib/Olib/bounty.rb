module Olib
  class Bounty
    @@listeners            = {}
    @@re                    = {}
    @@re[:herb]             = /requires (?:a|an|some) (?<herb>[a-zA-Z '-]+) found (?:in|on|around) (?<area>[a-zA-Z '-]+).  These samples must be in pristine condition.  You have been tasked to retrieve (?<number>[\d]+)/
    @@re[:escort]           = /Go to the (.*?) and WAIT for (?:him|her|them) to meet you there.  You must guarantee (?:his|her|their) safety to (?<destiniation>[a-zA-Z '-]+) as soon as/
    @@re[:gem]              = /has received orders from multiple customers requesting (?:a|an|some) (?<gem>[a-zA-Z '-]+).  You have been tasked to retrieve (?<number>[0-9]+)/
    @@re[:heirloom]         = /You have been tasked to recover ([a-zA-Z '-]+) that an unfortunate citizen lost after being attacked by (a|an|some) (?<creature>[a-zA-Z '-]+) (in|on|around|near|by) (?<area>[a-zA-Z '-]+)./
    @@re[:heirloom_found]   = /^You have located the heirloom and should bring it back to/
    @@re[:succeeded]        = /^You have succeeded in your task and can return to the Adventurer's/                          
    @@re[:report_to_guard]  = /^You succeeded in your task and should report back to/
    @@re[:cull]             = /^You have been tasked to suppress (?<creature>^((?!bandit).)*$) activity (?:in|on) (?:the )? (?<area>.*?)(?: near| between| under|\.) ([a-zA-Z' ]+).  You need to kill (?<number>[0-9]+)/
    @@re[:bandits]          = /^You have been tasked to suppress bandit activity (?:in |on )(?:the )(?<area>.*?)(?: near| between| under) ([a-zA-Z' ]+).  You need to kill (?<number>[0-9]+)/
    @@re[:dangerous]        = /You have been tasked to hunt down and kill a particularly dangerous (?<creature>.*) that has established a territory (?:in|on) (?:the )?(?<area>.*?)(?: near| between| under|\.)/
    @@re[:get_skin_bounty]  = /The local furrier/
    @@re[:get_rescue]       = /It appears that a local resident urgently needs our help in some matter/
    @@re[:get_bandits]      = /It appears they have a bandit problem they'd like you to solve./
    @@re[:get_heirloom]     = /It appears they need your help in tracking down some kind of lost heirloom/
    @@re[:get_herb_bounty]  = /local herbalist|local healer|local alchemist/
    @@re[:get_gem_bounty]   = /The local gem dealer, (?<npc>[a-zA-Z ]+), has an order to fill and wants our help/
    @@re[:creature_problem] = /It appears they have a creature problem they\'d like you to solve/
    @@re[:rescue]           = /A local divinist has had visions of the child fleeing from (?:a|an) (?<creature>.*) (?:in|on) (?:the )?(?<area>.*?)(?: near| between| under|\.)/
    @@re[:failed]           = /You have failed in your task/
    @@re[:none]             = /You are not currently assigned a task/

    # convenience list to get all types of bounties
    def Bounty.types
      @@re.keys
    end
    ##
    ## @brief      provides an accessor to the raw regular expression dictionary for Bounty logic
    ##
    ## @return     Bounty Regex
    ##
    def Bounty.regex
      @@re
    end

    def Bounty.town
      Bounty.current[:town]
    end

    def Bounty.area
      Bounty.current[:area]
    end

    def Bounty.destination
      Bounty.current[:destiniation]
    end

    def Bounty.gem
      Bounty.current[:gem]
    end

    def Bounty.creature
      Bounty.current[:creature]
    end

    def Bounty.herb
      Bounty.current[:herb]
    end

    def Bounty.n
      Bounty.current[:number].to_i
    end

    def Bounty.type
      Bounty.current[:type]
    end

    def Bounty.task
      Bounty.current
    end

    def Bounty.current
      info = nil
      bounty_str = checkbounty.strip
      Bounty.regex.each do |type, exp|
        if data = exp.match(bounty_str) then
          info = data.names.length ? Hash[ data.names.map(&:to_sym).zip( data.captures ) ] : {}
          info[:type] = type
        end
      end
      return info || {}
    end

    def Bounty.ask_for_bounty
      fput "ask ##{Bounty.npc.id} for bounty"
    end

    def Bounty.remove
      Go2.advguild
      2.times do fput "ask ##{Bounty.npc.id} for remove" end
    end

    def Bounty.to_s
        @@listeners.to_s
    end

    def Bounty.on(namespace, &block)
      @@listeners[namespace] = block
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
      return Bounty
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
      raise Errors::Fatal.new msg
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

    def Bounty.npc
      GameObj.npcs.select { |npc| npc.name =~ /guard|taskmaster|gemcutter|jeweler|akrash|kris|healer|dealer/i }.first
    end

  end
end

class Bounty < Olib::Bounty
end