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

module Group
  class Members
    include Enumerable
    attr_accessor :leader, :members, :birth
    def initialize
      @birth   = Time.now
      @members = []
    end

    def clear!
      @members = []
      @birth   = Time.now
      @leader  = nil
    end

    def size
      @members.size
    end

    def empty?
      @members.empty?
    end

    def add(pc, leader = false)      
      member = Member.new pc, leader
      if leader
        @leader = member
      end
      @members << member
      self
    end

    def each(&block)
      @members.each { |char| yield char }
      self
    end

    def include?(pc)
      select { |char| char.name == pc }
    end

    def nonmembers
      (GameObj.pcs || []).reject do |pc|
        @members.include?(pc)
      end
    end

    def to_s
      "<Members: [#{@members.join(" ")}]>"
    end
  end

  class Member
    attr :id, :leader
    def initialize(pc, leader = false)
      @id     = pc.id
      @leader = leader
    end

    private def ref
      GameObj[@id]
    end

    def leader?
      @leader
    end

    def name
      ref.name.split.pop
    end

    def status
      (ref.status.split(" ") || []).map(&:to_sym)
    end

    def is(state)
      status =~ state
    end

    def ==(other)
      @id == other.id
    end

    def to_s
      "<#{name}: @leader=#{leader?} @status=#{status}>"
    end
  end

  MEMBERS    = Members.new
  OPEN       = :open
  CLOSED     = :closed
  CHECK_HOOK = self.name.to_s
  NO_GROUP   = /You are not currently in a group/
  MEMBER     = /<a exist="(?<id>.*?)" noun="(?<name>.*?)">(.*?)<\/a> is (?<type>(the leader|also a member) of your group|following you)\./
  STATE      = /^Your group status is currently (?<state>open|closed)\./
  END_GROUP  = /list of other options\./

  PARSER = Proc.new do |line|
    
    if line.strip.empty? || line =~ NO_GROUP
      nil
    elsif line =~ STATE
      nil
    elsif line =~ END_GROUP
      Group.checked!
      DownstreamHook.remove(CHECK_HOOK)
      nil
    elsif line =~ MEMBER
      begin
        pc = line.match(MEMBER).to_struct
        Group::MEMBERS.add GameObj[pc.name], (line =~ /leader/ ? true : false)
        if line =~ /following/
          Group::MEMBERS.leader = OpenStruct.new(name: Char.name, leader: true)
        end
        nil 
      rescue Exception => e
        respond e
        respond e.backtrace
      end
    else
      line
    end
  end

  @@checked  = false

  def Group.checked?
    @@checked
  end

  def Group.checked!
    @@checked = true
    self
  end

  def Group.empty?
    MEMBERS.empty?
  end

  def Group.exists?
    !empty?
  end

  def Group.members
    maybe_check
    MEMBERS
  end

  def Group.to_s
    MEMBERS.to_s
  end

  # ran at the initialization of a script
  def Group.check
    @@checked = false
    MEMBERS.clear!
    DownstreamHook.add(CHECK_HOOK, PARSER)
    Game._puts "<c>group\r\n"
    wait_until { Group.checked? }
    MEMBERS
  end

  def Group.maybe_check
    Group.check unless checked?
  end

  def Group.nonmembers
    members.nonmembers
  end

  def Group.leader
    members.leader
  end

  def Group.leader?
    leader && leader.name == Char.name
  end
end