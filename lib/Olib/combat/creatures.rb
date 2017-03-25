require 'Olib/interface/queryable'
require 'net/http'
require 'json'
# a collection for managing all of the creatures in a room

class Creatures < Interface::Queryable

  METADATA_URL = "https://rawgit.com/ondreian/gemstone_data_project/master/creatures.json"
  
  ARCHETYPES = [
    :undead, :living, :weak, :grimswarm,
    :antimagic, :flying, :lowly, :bandit,
    :aggressive,
  ]

  STATES = [
    :dead, :sleeping, :webbed, :immobile,  
    :stunned, :prone, :sitting, 
    :kneeling, :flying
  ]

  def Creatures.fetch_metadata!
    begin
      JSON.parse Net::HTTP.get URI METADATA_URL
    rescue
      puts $!
      puts $!.backtrace[0..1]
      []
    end
  end

  METADATA = fetch_metadata!

  def Creatures.fetch
    (GameObj.npcs || [])
      .map do |obj| Creature.new obj end
      .select do |creature| 
        creature.aggressive? && !creature.tags.include?(:companion) && !creature.tags.include?(:familiar)
      end
  end

  [ARCHETYPES, STATES].flatten.each do |state|
    Creatures.define_singleton_method(state) do
      select do |creature|
        [creature.tags, creature.status].flatten.include?(state)
      end
    end
  end

  def self.living
    reject do |creature|
      creature.undead?
    end
  end

  def self.bounty
    select do |creature|
      creature.name.include?(Bounty.creature)
    end
  end
end
