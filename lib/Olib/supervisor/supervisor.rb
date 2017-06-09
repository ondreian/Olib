require "ostruct"
require "fiber"
require "thread"
##
## @brief      Class for Supervisor.
##
class Supervisor
  ##
  ## the amount of time in seconds between each yield
  ##
  TICK = 0.1
  TREE = {}

  def self.register(supervisor)
    TREE[supervisor.name] = supervisor
  end

  def self.fetch(name)
    TREE.fetch(name)
  end

  def self.unregister(supervisor)
    TREE.delete(supervisor.name)
  end

  def self.exists?(name)
    TREE.has_key?(name)
  end

  attr_accessor :fibers, :cleanup, :name, :debug
  ##
  ## @brief     creates a Supervisor instance
  ##
  ## @return    self
  ##
  def initialize(name)
    supervisor = self

    if Supervisor.exists?(name)
      raise Exception.new "a Supervisor with the name #{name} already exists.  They are required to be unique"
    end

    @fibers     = []
    @pre_hooks  = []
    @post_hooks = []
    @name       = name
    @debug      = false
    @cleanup    = [Proc.new do
      Supervisor.unregister(supervisor) 
    end]
    
    Supervisor.register(supervisor)
    before_dying { cleanup! }
  end
  ##
  ## @brief      returns if the Supervisor is in debug mode
  ##
  ## @return     Boolean
  ##
  def debug?
    @debug
  end
  ##
  ## @brief      turn on debug mode for a Supervisor
  ##
  ## @return     self
  ##
  def debug!
    @debug = true
    self
  end

  def debug(msg)
    if debug?
      _respond(msg)
    end
  end
  ##
  ## @brief      add a hook to the Supervisor tree
  ##
  ## @param      name  The name
  ## @param      hook  The hook
  ##
  ## @return     self
  ##
  def add(name, &hook)
    @fibers << [name, Fiber.new do
      loop do
        Fiber.yield hook.call
      end        
    end]
    self
  end
  ##
  ## @brief      hooks that run before every tick
  ##
  ## @param      name  The name
  ## @param      hook  The hook
  ##
  ## @return     self
  ##
  def pre_hook(name, &hook)
    @pre_hooks << [name, Fiber.new do
      loop do
        Fiber.yield hook.call
      end        
    end]
    self
  end
  ##
  ## @brief      hooks that run after every tick
  ##
  ## @param      name  The name
  ## @param      hook  The hook
  ##
  ## @return     self
  ##
  def post_hook(name, &hook)
    @post_hooks << [name, Fiber.new do
      loop do
        Fiber.yield hook.call
      end        
    end]
    self
  end
  ##
  ## @brief      add a cleanup task to the Supervisor tree
  ##
  ## @param      hook  The hook
  ##
  ## @return     self
  ##
  def cleanup(&hook)
    debug "cleanup -> #{@fibers.size} fibers  -> [" + @fibers.map(&:first).join(", ") + "]"
    debug "cleanup -> #{@cleanup.size} procs"
    @cleanup << hook
    self
  end
  ##
  ## @brief      cleanup a Supervisor tree
  ##
  ## @return     self
  ##
  def cleanup!
    @cleanup.each(&:call)
    self
  end
  ##
  ## @brief      attach a supervisor tree to the current Script
  ##
  ## @return     nil
  ##
  def link!    
    loop do
      run!
      sleep TICK
    end
    nil
  end
  ##
  ## @brief      one event loop of the Supervisor
  ##
  ## @return     nil
  ##
  def run!
    @fibers.map(&:last).each do |fiber|
      run_pre_hooks!
      fiber.resume
      run_post_hooks!
    end
  end
  def run_post_hooks!
    @post_hooks.map(&:last).map(&:resume)
  end

  def run_pre_hooks!
    @pre_hooks.map(&:last).map(&:resume)
  end
  ##
  ## @brief      converts a Supervisor to a Proc, useful for building
  ##             trees from Named Supervisors
  ##
  ## @return     Proc
  ##
  def to_proc
    supervisor = self
    return Proc.new do
      debug "running child supervisor :#{supervisor.name}"
      supervisor.run!
    end
  end
  ##
  ## @brief      build a supervisor tree by joining two supervisors
  ##
  ## @param      supervisor  The supervisor
  ##
  ## @return     self
  ##
  def join(*supervisors)
    supervisors.each do |supervisor|
      add supervisor.name, &supervisor.to_proc
    end
    self
  end
end