module Psycellium
  ##
  ##  Inbox that received remote requests
  ##
  class Inbox
    ##
    ## registry of all local inboxes
    ##
    REGISTRY = Hash.new
    ##
    ## only one job should be running at a time across all inboxes
    ##
    LOCK     = Mutex.new
    ##
    ## check if an inbox exists locally
    ##
    def self.exists?(name)
      !REGISTRY[name.to_sym].nil?
    end
    ##
    ## fetches an inbox from the registry
    ##
    def self.fetch(name)
      REGISTRY[name.to_sym]
    end
    ##
    ## adds a message to a local inbox
    ##
    def self.add(inbox, message)
      if exists?(inbox)
        fetch(inbox) << message
      else
        raise InvalidInbox.new(inbox)
      end
    end
    ##
    ## CAST operations are fire and forget operations
    ## the requestor does not expect or want a response
    ##
    def self.handle_cast(name = Script.current.name, &block)
      Inbox.new(name).handle_cast(&block)
    end
    ##
    ## CALL operations require a response
    ##
    def self.handle_call(name = Script.current.name, &block)
      Inbox.new(name).handle_call(&block)
    end

    attr_reader :name, :incoming, :callback, :event_loop,
                :high_water
    ##
    ## create an inbox with the given name
    ## names must be unique
    ##
    def initialize(name, high_water = 10)
      @name       = name.to_sym
      @high_water = high_water
      if Inbox.exists?(@name)
        raise InboxExists.new(name)
      end
      debug ":create"
      @incoming   = Queue.new
      @callback   = Try.new # noop
      @event_loop = Psycellium.track_resource(Thread.new do
        Thread.current[:name] = @name
        loop do
          unless @incoming.empty?
            LOCK.synchronize do
              msg = @incoming.shift
              debug "running #{msg}"
              Psycellium.debug_attempt @callback.call(msg)
            end
          end
          sleep 0.1
        end
      end)
      REGISTRY[@name] = self
    end

    def debug(msg)
      Psycellium.debug msg, "inbox.#{@name}"
    end
    ##
    ## schedules an operation in this queue
    ##
    def <<(msg)
      @incoming << msg
      debug "enqueued #{msg} Queue.size<#{@incoming.size}>"
      self
    end

    def handle_call(&block)
      @callback = Proc.new do |msg|
        Psycellium.debug_attempt(try do 
          result = block.call(msg)
          if msg.type == DSL::REQUEST && result.type == DSL::RESPONSE
            Psycellium::Session.response result
          elsif  msg.type == DSL::REQUEST
            raise Exception.new "request did not have a response"
          end
        end)
      end
      self
    end

    def handle_cast(&block)
      @callback = Proc.new do |msg|
        Psycellium.debug_attempt(try do 
          block.call(msg)
        end)
      end
      self
    end
  end

  class InboxExists < Exception
    def initialize(name)
      super("
        Inbox<#{name}> already exists
        make sure something is registering it on this character
      ")
    end
  end

  class InvalidInbox < Exception
    def initialize(name)
      super("
        Inbox<#{name}> does not exist
        make sure something is registering it on this character
      ")
    end
  end
end