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
    attr_accessor :wounds, :targetable, :can_cast, :type, :data, :legged, :limbed
     
    def initialize(creature)
      @wounds               = {}
      @data                 = {}
 
      @data[:type]          = 'unknown'
      @data[:trollish]      = creature.name =~ /troll|csetari/ ? true : false
      @data[:incapacitated] = false
       
      if creature.name =~ Gemstone_Regex.undead         then @data[:type] = 'undead';     @targetable = true;    end
      if creature.name =~ Gemstone_Regex.living         then @data[:type] = 'living';     @targetable = true;    end
      if creature.name =~ Gemstone_Regex.antimagic      then @data[:type] = 'antimagic';  @targetable = true;    end
      if creature.noun =~ Gemstone_Regex.bandits        then @data[:type] = 'bandit';     @targetable = true;    end
      if creature.noun =~ Gemstone_Regex.escortees      then @data[:type] = 'escortee';   @targetable = false;   end
      if creature.name =~ /taladorian/i                       then @data[:type] = 'invasion';   @targetable = true;    end
      if creature.name =~ /grimswarm/i                        then @data[:type] = 'grimswarm';  @targetable = true;    end
      if creature.noun =~ /kobold|rolton|velnalin|urgh/       then @data[:type] = 'ignoreable'; @targetable = true;    end
      heal
      # call the Gameobj_Extender initialize method that copies the game properties to this class
      super(creature)
    end
 
    def type
      @data[:type]
    end
 
    def is?(t)
      type == t
    end
 
    def bandit?
      type == 'bandit'
    end
 
    def grimswarm?
      type == "grimswarm"
    end
 
    def heal
      [:right_leg, :left_leg, :right_arm, :left_arm, :head, :neck, :chest, :abdomen, :back, :left_eye, :right_eye, :right_hand, :left_hand, :nerves].each do |location| @wounds[location] = 0 end
      @wounds
    end
     
    def injuries
      fput "look ##{@id}"
	  woundinfo = matchtimeout(2, /(he|she|it) (?:has|appears to be in good) .*/i)
      if woundinfo =~ /appears to be in good shape/													then heal; return @wounds;      end
	  if woundinfo =~ /some minor cuts and bruises on (his|her|its) right (?:hind )?leg/			then @wounds[:right_leg]  = 1;  end
	  if woundinfo =~ /some minor cuts and bruises on (his|her|its) left (?:hind )?leg/				then @wounds[:left_leg]   = 1;  end
	  if woundinfo =~ /some minor cuts and bruises on (his|her|its) (?:right arm|right foreleg)/	then @wounds[:right_arm]  = 1;  end
	  if woundinfo =~ /some minor cuts and bruises on (his|her|its) (?:left arm|left foreleg)/		then @wounds[:left_arm]   = 1;  end
	  if woundinfo =~ /minor bruises around (his|her|its) neck/										then @wounds[:neck]       = 1;  end
	  if woundinfo =~ /minor bruises around (his|her|its) head/										then @wounds[:head]       = 1;  end
	  if woundinfo =~ /minor cuts and bruises on (his|her|its) chest/								then @wounds[:chest]      = 1;  end
	  if woundinfo =~ /minor cuts and bruises on (his|her|its) abdomen/								then @wounds[:abdomen]    = 1;  end
	  if woundinfo =~ /minor cuts and bruises on (his|her|its) back/								then @wounds[:back]       = 1;  end
	  if woundinfo =~ /bruised left eye/															then @wounds[:left_eye]   = 1;  end
	  if woundinfo =~ /bruised right eye/															then @wounds[:right_eye]  = 1;  end
	  if woundinfo =~ /some minor cuts and bruises on (his|her|its) right (?:hand|paw|claw)/		then @wounds[:right_hand] = 1;  end
	  if woundinfo =~ /some minor cuts and bruises on (his|her|its) left (?:hand|paw|claw)/			then @wounds[:left_hand]  = 1;  end
	  if woundinfo =~ /a strange case of muscle twitching/											then @wounds[:nerves]     = 1;  end
	  if woundinfo =~ /fractured and bleeding right (?:hind )?leg/									then @wounds[:right_leg]  = 2;  end
	  if woundinfo =~ /fractured and bleeding left (?:hind )?leg/									then @wounds[:left_leg]   = 2;  end
	  if woundinfo =~ /fractured and bleeding (?:right arm|right foreleg)/							then @wounds[:right_arm]  = 2;  end
	  if woundinfo =~ /fractured and bleeding (?:left arm|left foreleg)/							then @wounds[:left_arm]   = 2;  end
	  if woundinfo =~ /moderate bleeding from (his|her|its) neck/									then @wounds[:neck]       = 2;  end
	  if woundinfo =~ /minor lacerations about (his|her|its) head and a possible mild concussion/	then @wounds[:head]       = 2;  end
	  if woundinfo =~ /deep lacerations across (his|her|its) chest/									then @wounds[:chest]      = 2;  end
	  if woundinfo =~ /deep lacerations across (his|her|its) abdomen/								then @wounds[:abdomen]    = 2;  end
	  if woundinfo =~ /deep lacerations across (his|her|its) back/									then @wounds[:back]       = 2;  end
	  if woundinfo =~ /swollen left eye/															then @wounds[:left_eye]   = 2;  end
	  if woundinfo =~ /swollen right eye/															then @wounds[:right_eye]  = 2;  end
	  if woundinfo =~ /fractured and bleeding right (?:hand|paw|claw)/								then @wounds[:right_hand] = 2;  end
	  if woundinfo =~ /fractured and bleeding left (?:hand|paw|claw)/								then @wounds[:left_hand]  = 2;  end
	  if woundinfo =~ /a case of sporadic convulsions/												then @wounds[:nerves]     = 2;  end
      if woundinfo =~ /severed right (?:hind )?leg/													then @wounds[:right_leg]  = 3;  end
      if woundinfo =~ /severed left (?:hind )?leg/													then @wounds[:left_leg]   = 3;  end
      if woundinfo =~ /severed (?:right arm|right foreleg)/											then @wounds[:right_arm]  = 3;  end
      if woundinfo =~ /severed (?:left arm|left foreleg)/											then @wounds[:left_arm]   = 3;  end
	  if woundinfo =~ /snapped bones and serious bleeding from (his|her|its) neck/					then @wounds[:neck]       = 3;  end
      if woundinfo =~ /severe head trauma and bleeding from (his|her|its) ears/						then @wounds[:head]       = 3;  end
	  if woundinfo =~ /deep gashes and serious bleeding from (his|her|its) chest/					then @wounds[:chest]      = 3;  end
	  if woundinfo =~ /deep gashes and serious bleeding from (his|her|its) abdomen/					then @wounds[:abdomen]    = 3;  end
	  if woundinfo =~ /deep gashes and serious bleeding from (his|her|its) back/					then @wounds[:back]       = 3;  end
      if woundinfo =~ /blinded left eye/															then @wounds[:left_eye]   = 3;  end
      if woundinfo =~ /blinded right eye/															then @wounds[:right_eye]  = 3;  end
      if woundinfo =~ /severed right (?:hand|paw|claw)/												then @wounds[:right_hand] = 3;  end
      if woundinfo =~ /severed left (?:hand|paw|claw)/												then @wounds[:left_hand]  = 3;  end
	  if woundinfo =~ /a case of uncontrollable convulsions/										then @wounds[:nerves]     = 3;  end
      @wounds
    end
     
    def status
      GameObj[@id].status
    end
 
    def trollish?
      @data[:trollish]
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
      result      = dothistimeout "target ##{@id}", 3, /#{Olib::Gemstone_Regex.targetable.values.join('|')}/
      @targetable = result =~ Olib::Gemstone_Regex.targetable[:yes] ? true : false
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
