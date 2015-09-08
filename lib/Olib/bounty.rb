module Olib
    class Bounty
      @@procedures            = {}

      @@re                    = {}
      @@re[:herb]             = /requires (?:a|an|some) (?<herb>[a-zA-Z '-]+) found (?:in|on|around) (?<area>[a-zA-Z '-]+).  These samples must be in pristine condition.  You have been tasked to retrieve (?<number>[\d]+)/
      @@re[:escort]           = /Go to the (.*?) and WAIT for (?:him|her|them) to meet you there.  You must guarantee (?:his|her|their) safety to (?<destiniation>[a-zA-Z '-]+) as soon as/
      @@re[:gem]              = /has received orders from multiple customers requesting (?:a|an|some) (?<gem>[a-zA-Z '-]+).  You have been tasked to retrieve (?<number>[0-9]+)/
      @@re[:heirloom]         = /You have been tasked to recover ([a-zA-Z '-]+) that an unfortunate citizen lost after being attacked by (a|an|some) (?<creature>[a-zA-Z '-]+) (in|on|around|near|by) (?<area>[a-zA-Z '-]+)./
      @@re[:heirloom_found]   = /^You have located the heirloom and should bring it back to/
      @@re[:turn_in]          = /You have succeeded in your task and can return to the Adventurer's Guild to receive your reward/
      @@re[:guard_turn_in]    = /^You succeeded in your task and should report back to/
      @@re[:guard_bounty]     = /Go report to ([a-zA-Z ]+) to find out more/
      @@re[:cull]             = /^You have been tasked to suppress (?<creature>^((?!bandit).)*$) activity (?:in|on) (?:the )? (?<area>.*?)(?: near| between| under|\.) ([a-zA-Z' ]+).  You need to kill (?<number>[0-9]+)/
      @@re[:bandits]          = /^You have been tasked to suppress bandit activity (?:in |on )(?:the )(?<area>.*?)(?: near| between| under) ([a-zA-Z' ]+).  You need to kill (?<number>[0-9]+)/
      @@re[:dangerous]        = /You have been tasked to hunt down and kill a particularly dangerous (?<creature>.*) that has established a territory (?:in|on) (?:the )?(?<area>.*?)(?: near| between| under|\.)/
      @@re[:get_skin_bounty]  = /The local furrier/
      @@re[:get_herb_bounty]  = /local herbalist|local healer|local alchemist/
      @@re[:get_gem_bounty]   = /The local gem dealer, (?<npc>[a-zA-Z ]+), has an order to fill and wants our help/
      @@re[:creature_problem] = /It appears they have a creature problem they\'d like you to solve/
      @@re[:rescue]           = /A local divinist has had visions of the child fleeing from (?:a|an) (?<creature>.*) (?:in|on) (?:the )?(?<area>.*?)(?: near| between| under|\.)/
      @@re[:failed_bounty]    = /You have failed in your task/
      @@re[:no_bounty]        = /You are not currently assigned a task/

      # convenience list to get all types of bounties
      def Bounty.types
        @@re.keys
      end

      def Bounty.town
        checkbounty.match(@@re[ Bounty.type ])[:town]
      end

      def Bounty.area
        checkbounty.match(@@re[ Bounty.type ])[:area]
      end

      def Bounty.destination
        checkbounty.match(@@re[ Bounty.type ])[:destiniation]
      end

      def Bounty.gem
        checkbounty.match(@@re[ Bounty.type ])[:gem]
      end

      def Bounty.creature
          checkbounty.match(@@re[ Bounty.type ])[:creature]
      end

      def Bounty.herb
          checkbounty.match(@@re[ Bounty.type ])[:herb]
      end

      def Bounty.n
          checkbounty.match(@@re[ Bounty.type ])[:number].to_i
      end

      def Bounty.type
        t = nil
        @@re.each do |type, exp|
          t= type if checkbounty =~ exp
        end
        return t
      end

      def Bounty.current
          Bounty.type
      end

      def Bounty.ask_for_bounty
        fput "ask ##{Bounty.npc.id} for bounty"
      end

      def Bounty.to_s
          @@procedures.to_s
      end

      def Bounty.define_procedure(namespace, &block)
        @@procedures[namespace] = block
      end

      def Bounty.procedures
        @@procedures
      end

      def Bounty.cooldown?
        Spell[9003].active?
      end

      def Bounty.throw_missing_procedure
        msg = "\n"
        msg.concat "\nBounty.exec called for #{Bounty.current} without a defined procedure\n\n"
        msg.concat "define a procedure with:\n"
        msg.concat " \n" 
        msg.concat "   Bounty.define_procedure(:#{Bounty.current}) {\n" 
        msg.concat "      # do something\n"
        msg.concat "   }\n"
        msg.concat " \n"
        msg.concat "or rescue this error (Olib::Errors::Fatal) gracefully\n"
        msg.concat " \n"
        raise Errors::Fatal.new msg
      end

      def Bounty.exec(procedure=nil)

        if procedure
          if @@procedures[procedure]
            @@procedures[procedure].call
            return Bounty
          else 
            Bounty.throw_missing_procedure
          end
        end

        if @@procedures[Bounty.current]
          @@procedures[Bounty.current].call
          return Bounty
        else
          Bounty.throw_missing_procedure
        end

      end

      def Bounty.npc
        GameObj.npcs.select { |npc| npc.name =~ /guard|taskmaster|gemcutter|jeweler|akrash|healer/i }.first
      end

    end
end