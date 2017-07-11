require "socket"
require "Olib/psycellium/cluster"

module Psycellium
  ##
  ## local Psycellium session running for a particular character
  ##
  module Session
    @@socket   = nil
    @@queue    = Queue.new
    @@writer   = Queue.new
    @@requests = Hash.new

    def self.queue
      @@queue
    end

    def self.socket
      @@socket
    end

    def self.writer
      @@writer
    end

    def self.requests
      @@requests
    end
    ##
    ## links the session to a remote Psycellium cluster
    ##
    def self.link(host = Psycellium::Cluster::HOST, port = Psycellium::Cluster::PORT)
      if socket.nil? || socket.closed?
        @@socket = TCPSocket.open(host, port)
        attach
        read!
        write!
      end
      self
    end
    ##
    ## schedules the attach packet to the Psycellium cluster
    ##
    def self.attach
      writer << Message.new(type: DSL::ATTACH, to: Char.name)
    end
    ##
    ## schedules a message packet to the Psycellium cluster
    ##
    def self.message(to, inbox, **data)
      writer << Message.new(type: DSL::MESSAGE, to: to, inbox: inbox, data: data)
      self
    end
    ##
    ## schedules a response packet to the Psycellium cluster
    ##
    def self.response(message)
      writer << message
      self
    end
    ##
    ## schedules a request packet to the Psycellium cluster
    ##
    def self.request(to, inbox, **data, &block)
      message = Message.new(type: DSL::REQUEST, to: to, inbox: inbox, data: data)
      writer << message
      @@requests[message.uuid] = {
        callback: block,
        created_at: Time.now,
      }
      self
    end
    ##
    ## reads and sorts all incoming messages
    ##
    def self.read!
      Psycellium.track_resource(Thread.new do
        loop do
          # reconnect
          attach! if socket.closed?

          while !socket.closed? && incoming = socket.gets
            Psycellium.debug_attempt(try do 
              message = Psycellium::Message.from_string(incoming)
              Psycellium.debug message, "#{Char.name}.#{message.inbox}.incoming"
              if message.type == DSL::RESPONSE
                Psycellium.debug_attempt(try do
                  requests[message.uuid][:callback].call(message)
                end)
                requests.delete(message.uuid)
              else
                Psycellium.inbox(message.inbox) do |inbox|
                  inbox << message
                end
              end
            end)
          end
          sleep 1
        end
      end)
      self
    end
    ##
    ## generates a writer thread for all scheduled packets
    ##
    def self.write!
      Psycellium.track_resource(Thread.new do   
        loop do
          unless socket.nil? || writer.empty?
            Psycellium.debug_attempt(try do
              data = writer.shift
              Psycellium.debug data, :write
              socket.write data.to_json + "\r\n"
            end)
          end
          sleep 0.1
        end
      end)
      self
    end
  end
end