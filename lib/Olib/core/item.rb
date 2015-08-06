require 'Olib/core/extender'

module Olib
  # this is the structure for a base Object
  # wraps an instance of GameObj and adds the ability for tags, queries
  class Item < Olib::Gameobj_Extender
    attr_accessor :props
    # When created, it should be passed an instance of GameObj
    #
    # Example: 
    #          Olib::Item.new(GameObj.right_hand)
    def initialize(obj)
      @props = Hash.new

      @props[:name]       = obj.name
      @props[:after_name] = obj.after_name

      define :tags, []
      obj.type.split(',').map { |t| tag(t) }

      if is?('jar') && @props[:after_name] =~ /containing (.*+?)/
        tag Dictionary.gems[:singularize].call @props[:after_name].gsub('containing', '').strip
      end

      if is?('gem')
        tag Dictionary.gems[:singularize].call @props[:name]
      end

      if is?('jar') && @props[:after_name].nil?
        tag('empty')
      end

      if Vars.teleporter && Vars.teleporter == @props[:name]
        tag('teleporter')
      end

      super(obj)
    end

    def to_s
      @props.to_s
    end

    # determine if Item is something
    #
    # example:
    #          item.is?("jar")
    #
    def is?(tag)
      @props[:tags].include?(tag)
    end

    def tag(*tags)
      @props[:tags].concat(tags)
      self
    end

    def untag(*remove)
      @props[:tags] = @props[:tags].select { |tag| !remove.include?(tag) }
    end

    def tags
      @props[:tags]
    end

    def worn?
      GameObj.inv.collect { |item| item.id }.include? @id
    end

    def crawl
      take
      tap._inspect.read.look
      self
    end

    def buy
      fput action 'buy'
      self
    end

    def has?(key)
      !@props[key].nil?
    end

    def missing?(key)
      !has?(key)
    end

    def pullable?
      is? 'pullable'
    end

    def buyable?
      is? 'buyable'
    end

    def cost
      @props['cost']
    end

    def acquire_from_shop
      take
      if pullable?
        return pull
      else
        Olib.wrap(action "buy"){ |line|
          raise Olib::Errors::InsufficientFunds if line =~ /The merchant frowns/
          raise Olib::Errors::Mundane            if line =~ /You hand over/
        }
      end
      self
    end

    def in
      return self if has? 'contents'
      Olib.wrap(action 'look in') { |line|
        raise Olib::Errors::Mundane      if line=~/^There is nothing in there./
        
        # handle jar data
        if line =~ /Inside (.*?) you see (?<number>[\d]+) portion(|s) of (?<type>.*?).  It is (more than |less than|)(?<percent>[a-z ]+)./ 
          data = line.match(/Inside (.*?) you see (?<number>[\d]+) portion(|s) of (?<type>.*?).  It is (more than |less than|)(?<percentage>[a-z ]+)./)
          tag data[:percentage] == 'full' ? "full" : "partial"
          define :number, data[:number].to_i
          raise Olib::Errors::Mundane
        end

        #handle empty jars
        if line =~ /The (.*?) is empty./
          tag 'empty'
          raise Olib::Errors::Mundane
        end
      }
      self
    end

    def _drag(target)
      Olib.wrap("_drag ##{@id} ##{target.id}") { |line|
        # order of operations is important here for jars
        raise Olib::Errors::DoesntExist          if line =~ Dictionary.put[:failure][:ne]
        raise Olib::Errors::Mundane              if line =~ Dictionary.put[:success]
        
        if line =~ Dictionary.put[:failure][:full]
          tag 'full'
          raise Olib::Errors::ContainerFull
        end
      }
      self
    end

    def stash
      _drag GameObj[props['container']]
    end

    def shake
      # make sure we have a count so we need to match fewer lines
      self.in if is? 'jar' and missing? :number
      
      Olib.wrap(action "shake"){ |line|
        raise Olib::Errors::Fatal    if line =~ /you realize that it is empty/
        if line =~ /fall into your/
          @props[:number] = @props[:number]-1
          raise Olib::Errors::Fatal.new "Jar is now empty\n you should rescue this to handle it gracefully" if @props[:number] == 0
          raise Olib::Errors::Mundane
        end
      }
      self
    end

    def shop_sell(amt)
      if GameObj.right_hand.id != @id
        raise Olib::Errors::Fatal
      end

      Olib.wrap("shop sell #{amt}") {|line|
        raise Olib::Errors::Mundane if line =~ /^You place your/
        raise Olib::Errors::Fatal   if line =~ /There's no more room for anything else right now./
      }

    end


    def turn
      fput action 'turn'
      self
    end

    def action(verb)
      "#{verb} ##{@id}"
    end

    def add(*items)
      items.each { |item|
        item._drag(self)
      }
      self
    end

    def define(key, val)
      @props[key] = val
      self
    end

    def pull(onfailure=nil)
      refresh_instance = false
      original_right   = GameObj.right_hand
      original_left    = GameObj.left_hand
      Olib.wrap(action "pull") { |line|
        
        if line =~ /^You pull/
          if line =~ /There (are|is) ([\d]+) left/
            refresh_instance = true
          end
          raise Olib::Errors::Mundane
        end

        if line =~ /I'm afraid that you can't pull that./
          if onfailure
            onfailure.call(self)
          else 
            raise Olib::Errors::DoesntExist 
          end
        end
      }
      # for stacked items in shops
      if refresh_instance
        return Item.new(GameObj.left_hand) if original_left.nil? && !GameObj.left_hand.nil?
        return Item.new(GameObj.right_hand)
      end
      self
    end

    def give(target, onfailure=nil)
      Olib.wrap_stream("give ##{@id} to #{target}", 30) { |line|
        
      }

      self
    end

    def remove(onfailure=nil)
      
      unless GameObj.inv.map(&:id).include? @id
        if onfailure
          onfailure.call(self)
        else 
          raise Olib::Errors::DoesntExist 
        end
      end
      
      Olib.wrap(action "remove") { |line|        
        if line =~ /You cannot remove|You better get a sharp knife/
          if onfailure
            onfailure.call(self)
          else 
            raise Olib::Errors::DoesntExist 
          end
        end
          
        raise Olib::Errors::Mundane if GameObj.right_hand.id == @id || GameObj.left_hand.id == @id
      }
    
      self
    end

    def wear(onfailure=nil)
      if GameObj.right_hand.id != @id || GameObj.left_hand.id != @id
        if onfailure
          onfailure.call(self)
        else 
          raise Olib::Errors::DoesntExist 
        end      
      end

      Olib.wrap(action "wear") { |line|        
        if line =~ /You can't wear that.|You can only wear/
          if onfailure
            onfailure.call(self)
          else 
            raise Olib::Errors::DoesntExist 
          end
        end
        raise Olib::Errors::Mundane if GameObj.inv.map(&:id).include? @id
      }
    
      self

    end

    def analyze
      # reserved
    end

    def take
      return self if has? 'cost'

      Olib.wrap(action 'get') { |line|
        raise Errors::DoesntExist    if line=~ Olib::Dictionary.get[:failure][:ne]
        raise Errors::HandsFull      if line=~ Olib::Dictionary.get[:failure][:hands_full]
        raise Errors::TooHeavy       if line=~ Olib::Dictionary.get[:failure][:weight]
        
        if line=~ Olib::Dictionary.get[:success] 
          raise Olib::Errors::Mundane
        end  

        if line =~ Olib::Dictionary.get[:failure][:buy]
          define 'cost', line.match(Olib::Dictionary.get[:failure][:buy])[:cost].to_i
        end

        if line=~ /You'll have to buy it if you want it/
          tag 'buyable'
          raise Olib::Errors::Mundane
        end

        if line=~ /You can PULL/
          tag 'pullable'
          raise Olib::Errors::Mundane
        end

      }
      self
    end

    def _inspect

      return self if has? 'inspect'

      in_inspect = false

      Olib.wrap_stream(action 'inspect') { |line|

        raise Olib::Errors::Mundane  if line =~ /^<prompt/ and in_inspect

        # skip first inspect line because it's useless for info
        if line =~ /You carefully inspect|You carefully count|goat/
          in_inspect = true
        end


        if in_inspect
          
          if line =~ /^You estimate that (?:.*?) can store (?:a|an|some) ([a-zA-Z -]+) amount with enough space for ([a-zA-Z ]+)/
            @props['space']           = $1
            @props['number_of_items'] = $2
          end
            

          
          if line =~ /^You determine that you could wear the (.*?) ([a-zA-Z ]+)/
            @props['location']= $2
          end
          
          if line =~ /allows you to conclude that it is ([a-zA-Z ]+)/

            if line =~ Dictionary.size
              @props['shield_type'] = $1
            else
              Dictionary.armors.each do |type, re| @props['armor_type'] = type if line =~ re end
            end
            
          end

          if line =~ /suitable for use in unarmed combat/
            @props['weapon_type']= "uac"
          end

          if line =~ /requires skill in ([a-zA-Z ]+) to use effectively/
        
            @props['weapon_type']= $1
            if line =~ /It appears to be a modified ([a-zA-Z -]+)/
              @props['weapon_base']= $1
            else
              @props['weapon_base']= @noun
            end
          end            
          
          if line =~ /^It looks like this item has been mainly crafted out of ([a-zA-Z -]+)./
            @props['material']= $1
            raise Olib::Errors::Mundane
          end
          
          if line =~ /can hold liquids/
            @props['liquid_container']=true
          end

        end
        
      }
      
      return self
    end

    def look
      return self if has? 'show'
      Olib.wrap(action 'look') { |line|
        raise Olib::Errors::Mundane      if line=~/^You see nothing unusual.|^You can't quite get a good look at/
        define 'show', line  unless line=~/<prompt|You take a closer look/
      }
      self
    end

    def tap
      return self if has? 'description'
      Olib.wrap(action 'tap') { |line|
        next unless line=~ /You tap (.*?) (on|in)/
        define 'description', $1 
        raise Olib::Errors::Mundane         
      }
      self
    end

    def price
      return self if(has? 'price' or has? 'info')
      Olib.wrap(action 'get') { |line|

        if line =~ /(\d+) silvers/
          define 'price', line.match(/(?<price>\d+) silvers/)[:price]
          raise Olib::Errors::Mundane
        end

        if line =~ /You can't pick that up/
          define "info", true
          raise Olib::Errors::Mundane
        end

        Script.log "unmatched price: #{line}"
        
      }
      self
    end

    def read
      return self if has? 'read'
      scroll    = false
      multiline = false
      Olib.wrap_stream(action 'read') {  |line|

        raise Olib::Errors::Mundane  if line =~ /^<prompt/ and (multiline or scroll)
        raise Olib::Errors::Mundane if line =~ /There is nothing there to read|You can't do that./

        # if we are in a multiline state
        @props['read'] = @props['read'].concat line if multiline

        # capture spell
        if scroll && line =~ /\(([0-9]+)\) ([a-zA-Z'\s]+)/
            n    = $1
            name = $2
            spell = {'n' => $1, 'name' => $2}
            #Client.notify "Spell detected ... (#{$1}) #{$2}"
            @props['spells'].push spell

        # begin scroll
        elsif line =~ /It takes you a moment to focus on the/
          scroll = true
          @props['spells'] = Array.new 

        # open multiline
        elsif line =~ /^In the (.*?) language, it reads/
          multiline          = true
          @props['read']     = "#{line}\n"
          @props['language'] = $1

        # alert to unknown
        elsif line =~ /but the language is not one you know.  It looks like it's written in (.*?)./
          Script.log "Please find a friend that can read for #{$1} in #{XMLData.room_title}"
          echo "Please find a friend that can read for #{$1} in #{XMLData.room_title}"
          raise Olib::Errors::Mundane
       
        end
        
      }
      return self
    end

  end
  
end