module Psycellium
  class Node
    
    attr_reader :name, :socket, :cluster, :listener,
                :blacklisted
    ##
    ## initializes a node on a cluster
    ##
    def initialize(cluster, socket)
      @cluster  = cluster
      @socket   = socket
      @name     = :anonymous
      @listener = Psycellium.track_resource(Thread.new do
        while (incoming = @socket.gets)
          Psycellium.debug_attempt(try do
            incoming = Psycellium::Message.from_string(incoming)
            incoming.from = @name
            case incoming.type
            when DSL::ATTACH
              handle_attach(incoming)
            # route message to the proper node
            when DSL::MESSAGE
              handle_message(incoming)
            when DSL::RESPONSE
              handle_response(incoming)
            when DSL::REQUEST
              handle_request(incoming)
            else
              raise Exception.new "unhandled message Type<#{incoming.type}>"
            end
          end)
          sleep 0.1
        end
        cleanup!
      end)
    end
    ## 
    ## cleans up a diconnected session
    ##
    def cleanup!
      return if @name == :anonymous
      Psycellium.debug("#{@name}", :disconnected)
      Psycellium.cluster.nodes.delete(@name) 
    end
    ##
    ## kills a node
    ##
    def kill!
      @listener.kill.join
    end
    ##
    ## handle when a client announces who they are
    ##
    def handle_attach(incoming)
      @name = incoming.to
      Thread.current[:name] = @name
      Psycellium.cluster.nodes[@name] = self
      Psycellium.debug(":attached", @name)
    end

    def handle_message(incoming)
      Psycellium.cluster.lookup(incoming.to) do |node|
        node.forward(incoming)
      end
    end

    def handle_request(incoming)
      Psycellium.cluster.lookup(incoming.to) do |node|
        node.forward(incoming)
      end
    end

    def handle_response(incoming)
      Psycellium.cluster.lookup(incoming.to) do |node|
        node.forward(incoming)
      end
    end

    ## client
    def forward(message)
      Psycellium.debug_attempt(try do
        Psycellium.debug message, :forwarding
        @socket.write message.to_json + "\r\n"
      end)
    end
  end
end