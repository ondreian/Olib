module Olib

  class Dictionary
    def Dictionary.heirloom
      re = {}
      re[:is]       = /are the initials ([A-Z]{2})./
      re[:give]     = /Excellent.  I'm sure the person who lost this will be quite happy/
      re
    end

    def Dictionary.ignorable?(line)
      line =~ /You feel less drained|You feel at full magical power again|\[LNet\]|GSIV|moving stealthily into the room|glides into view|soars out of sight|You notice (.*?) moving stealthily out|[A-Z][a-z]+ says, "|(removes|put) a (.*?) from in (his|her)|just opened (a|an)|just went|You gesture|Your spell is ready|just bit the dust|joins the adventure|just arrived|returns home from a hard day of adventuring|no longer effective|You sense that your attunement|You do not feel drained anymore|You feel the magic of your spell depart/
    end

    def Dictionary.targetable
      re = {}
      re[:yes] = /^You are now targeting/
      re[:no]  = /^You can't target/
      re
    end
    def Dictionary.bounty
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
    def Dictionary.bandit_traps
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
    
    def Dictionary.shop
      db = {}
      db[:success]            = /^You hand over|You place your/
      db[:failure]            = {}
      db[:failure][:missing]  = /^There is nobody here to buy anything from/
      db[:failure][:silvers]  = /^The merchant frowns and says/
      db[:failure][:full]     = /^There's no more room for anything else/
      db[:failure][:own]      = /^Buy your own merchandise?/
      db
    end
    def Dictionary.gems
      re                         = {}
      # Expressions to match interaction with gems
      re[:appraise]              = {}
      re[:appraise][:gemshop]    = /inspects it carefully before saying, "I'll give you ([0-9]+) for it if you want to sell/
      re[:appraise][:player]     = /You estimate that the ([a-zA-Z '-]+) is of ([a-zA-Z '-]+) quality and worth approximately ([0-9]+) silvers/
      re[:appraise][:failure]    = /As best you can tell, the ([a-zA-Z '-]+) is of average quality/
      re[:singularize]           = proc{ |str| str.gsub(/ies$/, 'y').gsub(/zes$/,'z').gsub(/s$/,'').gsub(/large |medium |containing |small |tiny |some /, '').strip }
      re
    end
  
    def Dictionary.get
      re = {}
      re[:failure] = {}
      # Expressions to match `get` verb results
      re[:failure][:weight]       = /You are unable to handle the additional load/
      re[:failure][:hands_full]   = /^You need a free hand to pick that up/
      re[:failure][:ne]           = /^Get what/
      re[:failure][:buy]          = /is (?<cost>[0-9]+) (silvers|coins)/
      re[:failure][:race]         = /be (?<cost>[0-9]+) (silvers|coins) for someone like you/
      re[:failure][:pshop]        = /^Looking closely/
      re[:success]                = /^You pick up|^You remove|^You rummage|^You draw|^You grab|^You reach|^You already/
      re
    end
  
    def Dictionary.put
      re = {}
      re[:failure]        = {}    
      re[:failure][:full] = /^won't fit in the|is full!|filling it./
      re[:failure][:ne]   = /^I could not find what you were referring to/
      re[:success]        = /^You put|^You tuck|^You sheathe|^You slip|^You roll up|^You tuck|^You add|^You place/
      re
    end
    
    def Dictionary.jar(name=nil)
      if name
        return name.gsub(/large |medium |containing |small |tiny |some /, '').sub 'rubies', 'ruby'
      else
        return false
      end
    end

    def Dictionary.armors
      armors                           = Hash.new
      armors['robes']                  = /cloth armor/i
      armors['light leather']          = /soft leather armor that covers the torso only./i
      armors['full leather']           = /soft leather armor that covers the torso and arms./i 
      armors['reinforced leather']     = /soft leather armor that covers the torso, arms, and legs./i 
      armors['double leather']         = /soft leather armor that covers the torso, arms, legs, neck, and head./i
      armors['leather breastplate']    = /rigid leather armor that covers the torso only./i
      armors['cuirbouilli leather']    = /rigid leather armor that covers the torso and arms./i
      armors['studded leather']        = /rigid leather armor that covers the torso, arms, and legs./i
      armors['brigadine armor']        = /rigid leather armor that covers the torso, arms, legs, neck, and head./i
      armors['chain mail']             = /chain armor that covers the torso only./i
      armors['double chain']           = /chain armor that covers the torso and arms./i
      armors['augmented chain']        = /chain armor that covers the torso, arms, and legs./i
      armors['chain hauberk']          = /chain armor that covers the torso, arms, legs, neck, and head./i
      armors['metal breastplate']      = /plate armor that covers the torso only./i
      armors['augmented plate']        = /plate armor that covers the torso and arms./i
      armors['half plate']             = /plate armor that covers the torso, arms, and legs./i
      armors['full plate']             = /plate armor that covers the torso, arms, legs, neck, and head./i
      armors['DB']                     = /miscellaneous armor that protects the wearer in general/
      armors
    end

    def Dictionary.size
      /that it is a (?<size>.*) shield that protects/
    end

    def Dictionary.numbers
      numbers                          = Hash.new
      numbers['one']                   = 1
      numbers['two']                   = 2
      numbers['three']                 = 3
      numbers['four']                  = 4
      numbers['five']                  = 5
      numbers
    end

    def Dictionary.spiked
      /You also notice that it is spiked./i
    end

    def Dictionary.fusion
      /(?<orbs>.*?) spherical depressions adorn the (.*?), approximately the size and shape of a small gem/
    end

  end
end