# enables creature specific logic
# TODO
# - add flying types

require 'Olib/extender'
require 'Olib/dictionary'

module Olib
  class Creature < Gameobj_Extender
    attr_accessor :wounds, :targetable, :can_cast, :type, :data, :legged, :limbed, :room

    def initialize(creature)
      @wounds               = {}
      @data                 = {}

      @data[:type]          = 'unknown'
      @data[:trollish]      = creature.name =~ /troll|csetari/ ? true : false
      @data[:incapacitated] = false
      @room                 = Room.current
      
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
      [:right_leg, :left_leg, :right_arm, :left_arm, :head, :left_eye, :right_eye].each do |location| @wounds[location] = 0 end
      @wounds
    end
    
    def injuries
      fput "look ##{@id}"
      woundinfo = matchtimeout(2, /(he|she|it) (?:has|appears) .*/i)
      if woundinfo =~ /appears to be in good shape/                   then heal; return @wounds;     end
      if woundinfo =~ /severed right leg/                             then @wounds[:right_leg] = 3;  end
      if woundinfo =~ /severed left leg/                              then @wounds[:left_leg]  = 3;  end
      if woundinfo =~ /severed right arm/                             then @wounds[:right_arm] = 3;  end
      if woundinfo =~ /severed left arm/                              then @wounds[:left_arm]  = 3;  end
      if woundinfo =~ /severe head trauma and bleeding from .* ears/  then @wounds[:head]      = 3;  end
      if woundinfo =~ /blinded left eye/                              then @wounds[:left_eye]  = 3;  end
      if woundinfo =~ /blinded right eye/                             then @wounds[:right_eye] = 3;  end
      if woundinfo =~ /severed right hand/                            then @wounds[:right_hand]= 3;  end
      if woundinfo =~ /severed left hand/                             then @wounds[:left_hand] = 3;  end
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
      Client.notify "#{@name} >> #{location}"
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