require "json"
require "ostruct"

require "Olib/psycellium/dsl"
require "Olib/psycellium/inbox"
require "Olib/psycellium/cluster"
require "Olib/psycellium/session"
require "Olib/psycellium/message"

module Psycellium
  RESOURCES = ThreadGroup.new
  @@debug   = false

  def self.debug!
    @@debug = true
  end

  def self.debug
    @@debug
  end

  def self.debug?
    @@debug
  end

  def self.resources
    RESOURCES.list
  end

  def self.inboxes
    Psycellium::Inbox::REGISTRY.values
  end

  def self.debug(msg, label = :debug)
    if debug?
      respond "[Psycellium.#{label}] #{msg}"
    end
    self
  end

  def self.debug_attempt(attempt)
    if attempt.failed? 
      debug("error : #{attempt.result}\nstack:#{attempt.result.backtrace.join("\n\t")}", :failure)
    end
  end

  def self.cluster
    Psycellium::Cluster
  end

  def self.inbox(name)
    inbox = Psycellium::Inbox.fetch(name)
    unless inbox.nil?
      yield inbox
    end
  end

  def self.add_inbox(name)
    if Inbox.exists?(name)
      Inbox.fetch(name)
    else
      Inbox.new(name)
    end
  end

  def self.script_inbox
    add_inbox Script.current.name
  end
  
  def self.handle_cast(name, &block)
    add_inbox(name).handle_cast(&block)
  end

  def self.handle_call(name, &block)
    add_inbox(name).handle_call(&block)
  end

  def self.die!
    resources.each do |t|
      t.kill.join
    end
    resources.clear
  end

  def self.track_resource(thread)
    RESOURCES.add(thread)
    thread
  end

  def self.link(host = Cluster::HOST, port = Cluster::PORT)
    unless Psycellium::Cluster.exists?
      Psycellium::Cluster.link(host, port)
    end
    Psycellium::Session.link(host, port)
  end

  def self.link!
    self.link
  end

  def self.register!
    Psycellium::Session.add_inbox(Script.current.name)
  end

  def self.session
    Psycellium::Session
  end

  def self.cleanup!
    Psycellium.cluster.nodes.clear
    Psycellium::Cluster.close
    Psycellium::Session.socket.close
    Psycellium.die!
  end
end
