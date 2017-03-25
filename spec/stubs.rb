require "ostruct"

class String
  def is_i?
    !!(self =~ /\A[-+]?[0-9]+\z/)
  end
end

class MatchData
  def to_struct
    OpenStruct.new to_hash
  end

  def to_hash
    Hash[self.names.zip(self.captures.map(&:strip).map do |capture|  
      if capture.is_i? then capture.to_i else capture end
    end)]
  end
end

class Hash
  def to_struct
    OpenStruct.new self
  end
end

class Regexp
  def or(re)
    Regexp.new self.to_s + "|" + re.to_s
  end
  # define union operator for regex instance
  def |(re)
    self.or(re)
  end
end

class Stubs
  @@bounty = nil
  @@mind   = nil

  def Stubs.bounty
    @@bounty
  end

  def Stubs.bounty=(bounty)
    @@bounty=bounty
  end

  def Stubs.mind
    @@mind
  end

  def Stubs.mind=(mind)
    @@mind=mind
  end
end

def checkbounty
  Stubs.bounty
end

def checkmind
  Stubs.mind
end

def fput
  true
end

def multifput(*args)
  args.each { |arg| fput arg }
end

def variable
  ["running_in_spec"]
end

def echo(*args)
  puts *args if debug
end

def wait_while(*)
  true
end

def wait_until(*)
  true
end

def start_script(*); end

class GameObj
  def self.npcs
    []
  end
  def self.pcs
    []
  end
end
class Spell ; end

UserVars = {}
Settings = {}
CharSettings = {}