module Verbs
  def __verbs__
    @verbs = "open close analyze inspect weigh".split(" ").map(&:to_sym)
    singleton = (class << self; self end)
    @verbs.each do |verb|
      singleton.send :define_method, verb do
        fput "#{verb.to_s} ##{@id}"
        self
      end
    end
  end

  def at
    Olib.wrap_stream("look at ##{@id}") { |line|
      if line =~ /You see nothing unusual|prompt time|You gaze through (.*?) and see...|written/
        raise Errors::Mundane
      end

      if line =~ /Looking at the (.*?), you see (?<nested>.*)/
        @nested = true

        @containers = line
          .match(/Looking at the (.*?), you see (?<nested>.*)/)[:nested]
          .scan(/<a exist="(?<id>.*?)" noun="(?<noun>.*?)">(?<name>.*?)<\/a>/)
          .map {|matches| Container.new GameObj.new *matches }
        raise Errors::Mundane
      end
      
    }
    self
  end

  def look
    self
  end

  def on
    return self unless @id
    Olib.wrap_stream("look on ##{@id}") { |line|
      raise Errors::Mundane if line =~ /There is nothing on there|prompt time/
      if line =~ /On the (.*?) you see/
        @ontop << line.match(Dictionary.contents)[:items]
          .scan(Dictionary.tag)
          .map {|matches| Item.new GameObj.new *matches }
        raise Errors::Mundane
      end
      next
    }
    self
  end

  def in
    fput "look in ##{@id}"
    self
  end

  def _inspect

    return self if has? "inspect"

    in_inspect = false

    Olib.wrap_stream(action "inspect") { |line|

      raise Errors::Mundane  if line =~ /^<prompt/ and in_inspect

      # skip first inspect line because it"s useless for info
      in_inspect = true if line =~ /You carefully inspect|You carefully count|goat/

      if in_inspect
        
        if line =~ /^You estimate that (?:.*?) can store (?:a|an|some) ([a-zA-Z -]+) amount with enough space for ([a-zA-Z ]+)/
          @props["space"]           = $1
          @props["number_of_items"] = $2
        end
          

        
        if line =~ /^You determine that you could wear the (.*?) ([a-zA-Z ]+)/
          @props["location"]= $2
        end
        
        if line =~ /allows you to conclude that it is ([a-zA-Z ]+)/

          if line =~ Dictionary.size
            @props["shield_type"] = $1
          else
            Dictionary.armors.each do |type, re| @props["armor_type"] = type if line =~ re end
          end
          
        end

        if line =~ /suitable for use in unarmed combat/
          @props["weapon_type"]= "uac"
        end

        if line =~ /requires skill in ([a-zA-Z ]+) to use effectively/
      
          @props["weapon_type"]= $1
          if line =~ /It appears to be a modified ([a-zA-Z -]+)/
            @props["weapon_base"]= $1
          else
            @props["weapon_base"]= @noun
          end
        end            
        
        if line =~ /^It looks like this item has been mainly crafted out of ([a-zA-Z -]+)./
          @props["material"]= $1
          raise Errors::Mundane
        end
        
        if line =~ /can hold liquids/
          @props["liquid_container"]=true
        end

      end
      
    }
    
    return self
  end

  def look
    return self if has? "show"
    Olib.wrap(action "look") { |line|
      raise Errors::Mundane if line=~/^You see nothing unusual.|^You can"t quite get a good look at/
      define "show", line  unless line=~/prompt time|You take a closer look/
    }
    self
  end

  def tap
    return self if has? "description"
    Olib.wrap(action "tap") { |line|
      next unless line=~ /You tap (.*?) (on|in)/
      define "description", $1 
      raise Errors::Mundane         
    }
    self
  end

  def price
    return self if(has? "price" or has? "info")
    Olib.wrap(action "get") { |line|

      if line =~ /(\d+) silvers/
        define "price", line.match(/(?<price>\d+) silvers/)[:price]
        raise Errors::Mundane
      end

      if line =~ /You can"t pick that up/
        define "info", true
        raise Errors::Mundane
      end

      Script.log "unmatched price: #{line}"
      
    }
    self
  end

  def read
    return self if has? "read"
    scroll    = false
    multiline = false
    Olib.wrap_stream(action "read") {  |line|

      raise Errors::Mundane  if line =~ /^<prompt/ and (multiline or scroll)
      raise Errors::Mundane if line =~ /There is nothing there to read|You can"t do that./

      # if we are in a multiline state
      @props["read"] = @props["read"].concat line if multiline

      # capture spell
      if scroll && line =~ /\(([0-9]+)\) ([a-zA-Z"\s]+)/
          spell = OpenStruct.new(name: $2, num: $1.to_i)
          #Client.notify "Spell detected ... (#{$1}) #{$2}"
          @props["spells"].push spell

      # begin scroll
      elsif line =~ /It takes you a moment to focus on the/
        scroll = true
        @props["spells"] = Array.new 

      # open multiline
      elsif line =~ /^In the (.*?) language, it reads/
        multiline          = true
        @props["read"]     = "#{line}\n"
        @props["language"] = $1

      # alert to unknown
      elsif line =~ /but the language is not one you know.  It looks like it"s written in (.*?)./
        Script.log "Please find a friend that can read for #{$1} in #{XMLData.room_title}"
        echo "Please find a friend that can read for #{$1} in #{XMLData.room_title}"
        raise Errors::Mundane
      
      end
      
    }
    return self
  end

  def analyze
    fput "analyze ##{id}"
    should_detect = false
    begin
      Timeout::timeout(1) do
        while(line = get)
          next                        if Dictionary.ignorable?(line)
          next                        if line =~ /sense that the item is free from merchant alteration restrictions|and sense that the item is largely free from merchant alteration restrictions|these can all be altered by a skilled merchant|please keep the messaging in mind when designing an alterations|there is no recorded information on that item|The creator has also provided the following information/
          @props["max_light"] = true  if line =~ /light as it can get/
          @props["max_deep"]  = true  if line =~ /pockets could not possibly get any deeper/
          @props["max_deep"]  = false if line =~ /pockets deepened/
          @props["max_light"] = false if line =~ /talented merchant lighten/
          if line =~ /Casting Elemental Detection/
            should_detect = true 
            next 
          end
          break                       if line =~ /pockets deepened|^You get no sense of whether|light as it can get|pockets could not possibly get any deeper|talented merchant lighten/
          @props["analyze"] = String.new unless @props["analyze"]
          @props["analyze"].concat line.strip
          @props["analyze"].concat " "
        end
      end
    
    rescue Timeout::Error
      # Silent
    end
    detect if should_detect
    temp_analysis = @props["analyze"].split(".").map(&:strip).map(&:downcase).reject {|ln| ln.empty? }
    @props["analyze"] = temp_analysis unless temp_analysis.empty?
    return self
  end

  def take
    return self if has? "cost"

    Olib.wrap(action "get") { |line|
      raise Errors::DoesntExist    if line=~ Dictionary.get[:failure][:ne]
      raise Errors::HandsFull      if line=~ Dictionary.get[:failure][:hands_full]
      raise Errors::TooHeavy       if line=~ Dictionary.get[:failure][:weight]
      
      if line=~ Dictionary.get[:success] 
        raise Errors::Mundane
      end  

      if line =~ Dictionary.get[:failure][:buy]
        define "cost", line.match(Dictionary.get[:failure][:buy])[:cost].to_i
        raise Errors::Mundane
      end

      if line =~ /let me help you with that/
        raise Errors::Mundane
      end

      if line=~ /You"ll have to buy it if you want it/
        tag "buyable"
        raise Errors::Mundane
      end

      if line=~ /You can PULL/
        tag "pullable"
        raise Errors::Mundane
      end

    }
    self
  end

  def drop
    Script.log("#{Time.now} > dropped #{to_s}")
    fput action "drop"
    self
  end

  SOLD        = /([\d]+) silver/
  WRONG_SHOP  = /That's not quite my field/
  WORTHLESS   = /worthless/

  def sell
    take
    case result = dothistimeout("sell ##{id}", 3, Regexp.union(SOLD, WRONG_SHOP, WORTHLESS))
    when SOLD        then [:sold, OpenStruct.new(name: self.name, price: $1.to_i)]
    when WRONG_SHOP  then [:wrong_shop, self]
    when WORTHLESS   then [:worthless, self]
    else                  [:unhandled_case, result]
    end
  end

  def _drag(target)
    Olib.wrap("_drag ##{id} ##{target.id}") { |line|
      # order of operations is important here for jars
      raise Errors::DoesntExist          if line =~ Dictionary.put[:failure][:ne]
      raise Errors::Mundane              if line =~ Dictionary.put[:success]
      
      if line =~ Dictionary.put[:failure][:full]
        tag "full"
        raise Errors::ContainerFull
      end
    }
    self
  end

end