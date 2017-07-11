require "socket"
require "Olib/psycellium/node"

module Psycellium
  ##
  ## generates a local psycellium cluster
  ##
  module Cluster
    PORT = 8787
    HOST = "0.0.0.0"

    @@server   = nil
    @@port     = nil
    @@host     = nil
    @@acceptor = nil
    @@nodes    = Hash.new

    def self.host
      @@host
    end

    def self.port
      @@port
    end

    def self.server
      @@server
    end

    def self.nodes
      @@nodes
    end
    ##
    ## determines if a Cluster exists locally or not
    ##
    def self.exists?
      begin
        Timeout::timeout(1) do
          begin
            s = TCPSocket.new(HOST, PORT)
            s.close
            return true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            return false
          end
        end
      rescue Timeout::Error
        # silence is golden
      end
      return false
    end

    def self.close
      @@nodes.values.each(&:close)
      server.close
    end
    ##
    ## looks up an attached node
    ##
    def self.lookup(name)
      node = Psycellium.cluster.nodes[name]
      if node.nil?
        Psycellium.debug("dropping message to invalid node #{name}", :node)
      else
        yield node
      end
    end
    ## 
    ## binds the cluster to the port
    ##
    def self.link(host = HOST, port = PORT)
      @@host     = host
      @@port     = port
      @@server   = TCPServer.open(@@host, @@port)
      @@acceptor = Psycellium.track_resource(Thread.new do
        Thread.current[:name] = :cluster
        loop do
          Thread.start(server.accept) do |incoming|
            Psycellium::Node.new(self, incoming)
          end
        end
      end)
      Psycellium.debug "listening on #{PORT}", :cluster
    end
  end
end