require "ostruct"
require "fiber"
require "thread"
##
## event loop management
##
class Watcher
  TICK    = 0.1

  attr_accessor :threads, :fibers, :cleanup, 
                :lock, :debug
  def initialize
    @threads = []
    @fibers  = []
    @cleanup = []
    @lock    = Mutex.new
    @debug   = false
    before_dying { cleanup! }
  end
  
  def debug
    @debug
  end

  def debug!
    @debug = true
  end

  def cleanup!
    if debug
      respond "cleanup -> #{@fibers.size} fibers  -> [" + @fibers.map(&:first).join(", ") + "]"
      respond "cleanup -> #{@threads.size} threads -> [" + @threads.map(&:first).join(", ") + "]"
      respond "cleanup -> #{@cleanup.size} procs"
    end
    @threads.map(&:last).each(&:kill).each(&:join)
    @cleanup.each(&:call)
  end

  def link!    
    loop do
      @fibers.map(&:last).each(&:resume)
      sleep TICK
    end
  end

  def add(name, &hook)
    @fibers << [name, Fiber.new do
      loop do
        Fiber.yield hook.call
      end        
    end]
    self
  end

  def spawn(name, &routine)
    @threads << [name, Thread.new do 
      loop do
        @lock.synchronize do
          routine.call
          sleep TICK
        end
      end
    end]
  end

  def cleanup(&hook)
    @cleanup << hook
    self
  end
end