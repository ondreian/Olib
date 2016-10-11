require "ostruct"

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

class GameObj ; end
class Spell ; end

UserVars = {}
Settings = {}
CharSettings = {}