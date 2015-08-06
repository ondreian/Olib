# a collection for managing all of the creatures in a room
module Olib
  class Creatures

    def Creatures.first
      all.first
    end

    def Creatures.all
      GameObj.npcs
        .map    { |creature| Olib::Creature.new(creature) }
        .select { |creature| !creature.dead?              }
        .select { |creature| !creature.ignorable?         }
        .select { |creature| !creature.tags.include?('animate') }
        .select { |creature| !creature.gone? } || []
    end

    def Creatures.each(&block)
      all.each(&block)
    end

    def Creatures.[](exp)
      regexp = exp.class == String ? /#{exp}/ : exp

      all.select { |creature| creature.name =~ regexp || creature.id == exp }
    end
    
    def Creatures.filter(&block); 
      all.select(&block)                                
    end

    def Creatures.bandits;     all.select { |creature| creature.is?('bandit') }    ;end;
    def Creatures.ignoreable;  all.select { |creature| creature.is?('ignoreable') }    ;end;
    def Creatures.flying;      all.select { |creature| creature.is?('flying') }    ;end;
    def Creatures.living;      all.select { |creature| creature.is?('living') }    ;end;
    def Creatures.antimagic;   all.select { |creature| creature.is?('antimagic') } ;end;
    def Creatures.undead;      all.select { |creature| creature.is?('undead') }    ;end;

    def Creatures.grimswarm;   all.select { |creature| creature.is?('grimswarm') } ;end;
    def Creatures.invasion;    all.select { |creature| creature.is?('invasion')  } ;end;
    def Creatures.escortees;   GameObj.npcs.map {|creature| Creature.new(creature) }.select {|creature| creature.is?('escortee') } ;end;

    def Creatures.stunned;     all.select(&:stunned?)   ;end;
    def Creatures.active;      all.select(&:active?)    ;end;
    def Creatures.dead;        all.select(&:dead?)      ;end;
    def Creatures.prone;       all.select(&:prone?)     ;end;
    
    def Creatures.ambushed?
      last_line = $_SERVERBUFFER_.reverse.find { |line| line =~ /<pushStream id='room'\/>|An? .*? fearfully exclaims, "It's an ambush!"|#{Olib::Dictionary.bandit_traps.values.join('|')}/ }
      echo "detected ambush..." if !last_line.nil? && last_line !~ /pushStream id='room'/

      !last_line.nil? && last_line !~ /pushStream id='room'/
    end


  end
end