module Olib
  module Shop

    @@containers = []

    def Shop.items
      Shop.containers.map { |container| container.contents }.flatten
    end

    def Shop.containers
      #fput "look"
      @@containers = [
        GameObj.loot, 
        GameObj.room_desc
      ]
      .flatten
      .compact
      .select     { |container| !(container.name =~ /^([A-z][a-z]+ disk$)/)}
      .map        { |container| Shop::Container.new(container)  }

      @@containers

    end

    def Shop.cache
      @@containers
    end

    class Container < Olib::Gameobj_Extender
      attr_accessor :show, :nested, :containers, :id, :cache, :props

      def to_s
        info = {}
        info[:name]     = @name
        info[:noun]     = @noun
        info[:props]    = @props
        info[:cache]    = @cache
        info.to_s
      end
      
      def initialize(obj)
        @cache = Hash.new
        @props = Hash.new
        super(obj)
      end

      def action(verb)
        "#{verb} ##{@id}"
      end

      def look
        self
      end

      # detect nested containers
      def at
        
        Olib.wrap_stream(action 'look at') { |line|
          
          raise Olib::Errors::Mundane if line =~ /You see nothing unusual/

          if line =~ /Looking at the (.*?), you see (?<nested>.*)/
            @nested     = true

            @containers = line.match(/Looking at the (.*?), you see (?<nested>.*)/)[:nested].scan(/<a exist="(?<id>.*?)" noun="(?<noun>.*?)">(?<name>.*?)<\/a>/).map {|matches| 
              Container.new GameObj.new *matches
            }
            raise Olib::Errors::Prempt
          end
          
        }

        self
      end

      def nested?
        @nested || false
      end

      def in
        return self unless @id
        Olib.wrap_stream(action 'look in') { |line|
          raise Olib::Errors::Mundane if line=~ /^There is nothing in there|^That is closed|filled with a variety of garbage|Total items:/
          raise Olib::Errors::Prempt  if line =~ /^In the (.*?) you see/
        }
        self
      end

      def on
        return self unless @id
        Olib.wrap_stream(action 'look on') { |line|
          raise Olib::Errors::Mundane if line =~ /^There is nothing on there/
          raise Olib::Errors::Prempt  if line =~ /^On the (.*?) you see/
        }
        self
      end

      def contents
        look.in.on unless GameObj[@id].contents
        GameObj[@id].contents.map {|i| Item.new(i).define('container', @id) }
      end

      def containers
        @containers
      end 
    end
    
    class Playershop
      @@noncontainers = [ "wall", "ceiling", "permit", "floor", "helmet", "snowshoes",
                      "candelabrum", "flowerpot", "Hearthstone", "bear", "candelabra",
                      "sculpture", "anvil", "tapestry", "portrait", "Wehnimer", "spiderweb",
                      "rug", "fountain", "longsword", "ship", "panel", "painting", "armor",
                      "flowers", "head", "plate", "vase", "pillows", "mask", "skeleton", "fan",
                      "flag", "statue", "mat", "plaque", "mandolin", "plant", "sign" ]
      
      def Playershop.containers
        Shop.containers.reject { |container|
          @@noncontainers.include? container.noun
        }
      end

      def Playershop.balance
        balance = 0
        Olib.wrap_stream('shop withdraw') { |line|
          next if line =~ /^Usage: SHOP WITHDRAW <amount>/
          raise Olib::Errors::Prempt if line =~ /^You must be in your shop to do that.$/

          if line =~ /Your shop's bank account is currently ([\d]+)/
            balance = $1.to_i
            raise Olib::Errors::Prempt
          end

        }
        return balance
      end

      def Playershop.where(conditions)        
        Playershop.items.select { |item|
          !conditions.keys.map { |key|
            if conditions[key].class == Array
              item.props[key].class == Array && !conditions[key].map { |ele| item.props[key].include? ele }.include?(false)
            else
              item.props[key] == conditions[key]
            end
          }.include?(false)
        }
      end

      def Playershop.find_by_tags(*tags)
        
        Playershop.items.select { |item|
          !tags.map {|tag| item.is?(tag) }.include? false
        }
      end

      def Playershop.sign
        Shop.containers.select { |container|
          container.noun == 'sign'
        }[0]
      end

      def Playershop.items
        Playershop.containers.map { |container|
          container.contents
        }.flatten
      end
    end
  end

  def Olib.Playershop
    Olib::Shop::Playershop
  end

  def Olib.Shop
    Olib::Shop
  end
end