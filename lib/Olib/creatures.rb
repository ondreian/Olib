require 'Olib/creature'
# a collection for managing all of the creatures in a room
module Olib
  class Creatures
    attr_accessor :untargetables, :ignore, :collection
    def initialize(ignore=true)
      @ignore = ignore
      self
    end

    def first
      all.first
    end

    def all
      GameObj.npcs.map {|creature| Olib::Creature.new(creature) }.select {|creature| creature.targetable  && !creature.is?("ignoreable") && !creature.dead? && !creature.gone? } || []
    end

    def each(&block)
      all.each(&block)
    end

    def [](exp)
      regexp = exp.class == String ? /#{exp}/ : exp

      all.select { |creature| creature.name =~ regexp || creature.id == exp }
    end
    def bandits;     all.select { |creature| creature.is?('bandit') }    ;end;
    def flying;      all.select { |creature| creature.is?('flying') }    ;end;
    def living;      all.select { |creature| creature.is?('living') }    ;end;
    def antimagic;   all.select { |creature| creature.is?('antimagic') } ;end;
    def undead;      all.select { |creature| creature.is?('undead') }    ;end;

    def grimswarm;   all.select { |creature| creature.is?('grimswarm') } ;end;
    def invasion;    all.select { |creature| creature.is?('invasion')  } ;end;
    def escortees;   GameObj.npcs.map {|creature| Creature.new(creature) }.select {|creature| creature.is?('escortee') } ;end;

    def stunned;     all.select(&:stunned?)   ;end;
    def active;      all.select(&:active?)    ;end;
    def dead;        all.select(&:dead?)      ;end;
    def prone;       all.select(&:prone?)     ;end;
    
    def ambushed?
      last_line = $_SERVERBUFFER_.reverse.find { |line| line =~ /<pushStream id='room'\/>|An? .*? fearfully exclaims, "It's an ambush!"|#{Olib::Gemstone_Regex.bandit_traps.values.join('|')}/ }
      echo "detected ambush..." if !last_line.nil? && last_line !~ /pushStream id='room'/

      !last_line.nil? && last_line !~ /pushStream id='room'/
    end


  end
end