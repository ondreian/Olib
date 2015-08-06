module Olib
  class Bounty
    @@re                    = {}
    @@re[:herb]             = /requires (?:a|an|some) ([a-zA-Z '-]+) found (?:in|on|around) ([a-zA-Z '-]+).  These samples must be in pristine condition.  You have been tasked to retrieve ([0-9]+)/
    @@re[:escort]           = /Go to the (.*?) and WAIT for (?:him|her|them) to meet you there.  You must guarantee (?:his|her|their) safety to ([a-zA-Z '-]+) as soon as/
    @@re[:gem]              = /has received orders from multiple customers requesting (?:a|an|some) ([a-zA-Z '-]+).  You have been tasked to retrieve ([0-9]+)/
    @@re[:heirloom]         = /You have been tasked to recover ([a-zA-Z '-]+) that an unfortunate citizen lost after being attacked by (a|an|some) ([a-zA-Z '-]+) (in|on|around|near|by) ([a-zA-Z '-]+)./
    @@re[:heirloom_found]   = /^You have located the heirloom and should bring it back to/
    @@re[:turn_in]          = /You have succeeded in your task and can return to the Adventurer's Guild to receive your reward/
    @@re[:guard_turn_in]    = /^You succeeded in your task and should report back to/
    @@re[:guard_bounty]     = /Go report to ([a-zA-Z ]+) to find out more/
    @@re[:cull]             = /^You have been tasked to suppress (^((?!bandit).)*$) activity (?:in|on) (?:the )? (.*?)(?: near| between| under|\.) ([a-zA-Z' ]+).  You need to kill (?<n>[0-9]+)/
    @@re[:bandits]          = /^You have been tasked to suppress bandit activity (?:in |on )(?:the )(.*?)(?: near| between| under) ([a-zA-Z' ]+).  You need to kill ([0-9]+)/
    @@re[:dangerous]        = /You have been tasked to hunt down and kill a particularly dangerous (.*) that has established a territory (?:in|on) (?:the )?(.*?)(?: near| between| under|\.)/
    @@re[:get_skin_bounty]  = /The local furrier/
    @@re[:get_herb_bounty]  = /local herbalist|local healer|local alchemist/
    @@re[:get_gem_bounty]   = /The local gem dealer, ([a-zA-Z ]+), has an order to fill and wants our help/
    @@re[:creature_problem] = /It appears they have a creature problem they\'d like you to solve/
    @@re[:rescue]           = /A local divinist has had visions of the child fleeing from (?:a|an) (.*) (?:in|on) (?:the )?(.*?)(?: near| between| under|\.)/
    @@re[:failed_bounty]    = /You have failed in your task/
    @@re[:get_bounty]       = /You are not currently assigned a task/

    # convenience list to get all types of bounties
    def Bounty.types
      @@re.keys
    end

    def Bounty.type
      t = nil
      @@re.each do |type, exp|
        t= type if checkbounty =~ exp
      end
      return t
    end

    def Bounty.creature
    
    end

    def Bounty.gem
        
    end

    def Bounty.location
    end

    def Bounty.n

    end

  end
end