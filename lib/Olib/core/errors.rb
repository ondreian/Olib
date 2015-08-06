module Olib
  module Errors

    # used internally to handle early thread execution and error bubbling
    class Mundane < Exception
    end

    # used internally to insure threads died and error bubbling
    class TimedOut < Exception
    end

    # used internally to handle early thread execution and error bubbling
    class Prempt < Exception
    end

    # used to exit a thread early due to an error that Olib cannot resolve internally
    class Fatal < Exception
      def initialize(message=nil)
        unless message
          message = String.new
          message.concat "\n\nAn Olib::Errors::Fatal was raised but not rescued in an Olib method"
          message.concat "\nyou should rescue this error if it isn't fatal and you don't want your script to break"
        end
        super(message)
      end
    end 

    # If you have a full container and a script/action depends on it, this is thrown
    # rescue it for logic
    class ContainerFull < Exception
      def initialize(message=nil)
        unless message
          message = String.new
          message.concat "\n\nYou tried to add stuff to a container that was full"
          message.concat "\nyou should rescue this error if it isn't fatal and you don't want your script to break"
        end
        super(message)
      end
    end 
    
    class InsufficientFunds < Exception
      def initialize(message=nil)
        unless message
          message = String.new
          message.concat "\n\nYou tried to do something that costs more money that your character had on them"
          message.concat "\nyou should rescue this error if it isn't fatal and you don't want your script to break"
        end
        super(message)
      end
    end 

    class HandsFull < Exception
      def initialize
        message = String.new
        message.concat "\n\nYour hands were full!"
        message.concat "\nyou should rescue this error if you don't want your script to break"
        super(message)
      end
    end

    class TooHeavy < Exception
      def initialize
        message = String.new
        message.concat "\n\nYou were too heavy to do something!"
        message.concat "\nyou should rescue this error if you don't want your script to break"
        super(message)
      end
    end

    class DoesntExist < Exception
      def initialize(message=nil)
        unless message
          message = String.new
          message.concat "\n\nYou tried to interact with something that no longer exists"
          message.concat "\nyou should rescue this error if it isn't fatal and you don't want your script to break"
        end
        super(message)
      end
    end

  end
end