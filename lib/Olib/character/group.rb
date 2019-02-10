require "ostruct"
require "Olib/character/disk"

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
      @members.each do |char| yield char end
      self
    end

    def include?(pc)
      return true if pc.is_a?(String) and Char.name.eql?(pc)
      return true if pc.respond_to?(:noun) and Char.name.eql?(pc.noun)
      return true if pc.respond_to?(:name) and Char.name.eql?(pc.name)
      !find do |char|
        if pc.is_a?(String)
          char.noun.eql?(pc)
        else
          char.noun.eql?(pc.noun) || char.noun.eql?(pc.name)
        end
      end.nil?
    end

    def nonmembers
      ((GameObj.pcs || []) + Disk.all()).reject do |pc|
        include?(pc)
      end 
    end

    def to_s
      "<Members: [#{@members.join(" ")}]>"
    end
  end

  class Member
    attr_reader :id, :leader, :name, :noun
    def initialize(pc, leader = false)
      @id     = pc.id
      @leader = leader
      @name   = pc.name
      @noun   = pc.noun
    end

    def ref
      GameObj[@id]
    end

    def leader?
      @leader
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

  def Group.disks
    return [Disk.find_by_name(Char.name)].compact unless Group.leader?
    members.map(&:name).map do |name|  Disk.find_by_name(name) end.compact
  end
  
  def Group.to_s
    MEMBERS.to_s
  end

  # ran at the initialization of a script
  def Group.check
    Group.unobserve()
    @@checked = false
    MEMBERS.clear!
    DownstreamHook.add(CHECK_HOOK, PARSER)
    Game._puts "<c>group\r\n"
    wait_until { Group.checked? }
    Group.observe()
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


  module Term
    # <a exist="-10467645" noun="Oreh">Oreh</a> leaves your group
    # <a exist="-10467645" noun="Oreh">Oreh</a> joins your group.
    # You add <a exist="-10467645" noun="Oreh">Oreh</a> to your group.
    # You remove <a exist="-10467645" noun="Oreh">Oreh</a> from the group.
    # You disband your group.
    JOIN    = %r{^<a exist="(?<id>[\d-]+)" noun="(?<noun>[A-Za-z]+)">(?<name>\w+?)</a> joins your group.$}
    LEAVE   = %r{^<a exist="(?<id>[\d-]+)" noun="(?<noun>[A-Za-z]+)">(?<name>\w+?)</a> leaves your group.$}
    ADD     = %r{^You add <a exist="(?<id>[\d-]+)" noun="(?<noun>[A-Za-z]+)">(?<name>\w+?)</a> to your group.$}
    REMOVE  = %r{^You remove <a exist="(?<id>[\d-]+)" noun="(?<noun>[A-Za-z]+)">(?<name>\w+?)</a> from the group.$}
    NOOP    = %r{^But <a exist="(?<id>[\d-]+)" noun="(?<noun>[A-Za-z]+)">(?<name>\w+?)</a> is already a member of your group!$}
    EXIST   = %r{<a exist="(?<id>[\d-]+)" noun="(?<noun>[A-Za-z]+)">(?<name>\w+?)</a>}
    DISBAND = %r{^You disband your group}
    ANY     = Regexp.union(JOIN, LEAVE, ADD, REMOVE, NOOP)
  end

  GROUP_OBSERVER = -> line {
    begin
      return line if DownstreamHook.list.include?(CHECK_HOOK)
      Group.consume(line.strip)
    rescue => exception
      respond exception
      respond exception.backtrace
    end
    line
  }

  def self.observe()
    wait_while do DownstreamHook.list.include?(CHECK_HOOK) end
    DownstreamHook.add("__group_observer", GROUP_OBSERVER)
  end

  def self.unobserve()
    DownstreamHook.remove("__group_observer")
  end

  Group.observe()

  def self.consume(line)
    return unless line.match(Group::Term::ANY)
    person = GameObj[Term::EXIST.match(line)[:id]]
    case line
    when Term::JOIN
      Group.members.add(person) unless Group.members.include?(person)
    when Term::ADD
      Group.members.add(person) unless Group.members.include?(person)
    when Term::NOOP
      Group.members.add(person) unless Group.members.include?(person)
    when Term::LEAVE
      Group.members.members.delete(Group.members.find do |member|
        member.id.eql?(person.id)
      end)
    when Term::REMOVE
      Group.members.members.delete(Group.members.find do |member|
        member.id.eql?(person.id)
      end)
    else
      # silence is golden
    end
    Group.persist()
  end

  def self.add(*members)
    members.map do |member|
      if member.is_a?(Array)
        Group.add(*member)
      else
        result = dothistimeout("group ##{member.id}", 3, Regexp.union(
          %r{You add #{member.noun} to your group},
          %r{#{member.noun}'s group status is closed},
          %r{But #{member.noun} is already a member of your group}))
        
        case result
        when %r{You add}
          Group.members.add(member)
          [:ok, member]
        when %r{already a member}
          [:noop, member]
        when %r{closed}
          [:err, member]
        else
        end
      end
    end
  end

  def self.persist()
    return
  end

  def self.broken?
    if Group.leader?
      (GameObj.pcs.map(&:noun) & Group.members.map(&:noun)).size < Group.members.size
    else
      GameObj.pcs.find do |pc| pc.noun.eql?(Group.leader.noun) end.nil?
    end
  end
end