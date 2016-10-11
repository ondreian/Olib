module Olib
  class Group
    @@characters             = {}
    @@checked                = false
    @@characters[Char.name]  = true  # YOU CAN NEVER ESCAPE YOURSELF (so your own disk won't fuck up)
    @@leader                 = Char.name

    # ran at the initialization of a script
    def Group.check
      @@characters             = {}
      
      
      fput "group"
      while line=get
        break            if line =~ /You are not currently in a group/
        Group.define($1) if line =~ /([a-zA-Z]+) (is following you|is also a member of your group|is the leader of your group)/
        @@leader = $1    if line =~ /([a-zA-Z]+) is the leader of your group/
        break            if line =~ /^Your group status is/
      end
      @@checked = true
      @@characters
    end

    def Group.leader
      @@leader
    end

    def Group.leader?
      Group.check unless @@checked
      @@leader == Char.name
    end

    def Group.whisper(msg)
      fput "whisper group #{msg}" unless Group.members.empty?
    end
    
    def Group.add(char)
      fput "group #{char}"
      Group.define(char)
      self
    end

    def Group.remove(char)
      fput "remove #{char}"
      @@characters.delete(char)
      self
    end

    def Group.nonmembers
      Group.check unless @@checked
      others      = GameObj.pcs.map! {|char| char.noun } || []
      # find all the disks/hidden players too
      disk_owners = GameObj.loot.find_all { |obj| (obj.noun == 'disk') }.map{|disk| /([A-Z](?:[a-z]+))/.match(disk.name)[0].strip } || []
      [others, disk_owners].flatten.reject(&:nil?).uniq - @@characters.keys
    end

    def Group.members
      Group.check unless @@checked
      @@characters.keys
    end

    def Group.define(name)
      GameObj.pcs.detect do |pc| @@characters[name] = pc.dup if pc.noun == name end
    end
  end
end

class Group < Olib::Group
end