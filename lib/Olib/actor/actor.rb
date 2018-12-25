module Actor
  def self.included(klass)
    klass.class_variable_set(:@@supervisor, Supervisor.new(klass.name))
    klass.class_variable_set(:@@states, Array.new)
    klass.class_variable_set(:@@pre_hooks, Array.new)
    klass.class_variable_set(:@@post_hooks, Array.new)
    klass.class_variable_set(:@@state, nil)
    klass.class_variable_set(:@@history, Array.new)
    klass.extend Actor::Mixins
  end

  module Mixins

    def states
      self.class_variable_get(:@@states)
    end

    def pre_hooks
      self.class_variable_get(:@@pre_hooks)
    end

    def post_hooks
      self.class_variable_get(:@@post_hooks)
    end

    def state
      self.class_variable_get(:@@state)
    end

    def history
      self.class_variable_get(:@@history)
    end

    def supervisor
      self.class_variable_get(:@@supervisor)
    end

    def state=(state)
      class_variable_set(:@@state, state.to_sym)
    end

    def start(state)
      class_variable_set(:@@state, state.to_sym)
    end

    def emit(state)
      state = state.to_sym
      validate! state
      self
    end

    def to_s
      "#{self.name}<state=#{state} last=#{last} history=#{history} states=#{states}>"
    end

    def yield(state)
      emit(state)
      Fiber.yield
    end

    def is?(state)
      validate!(state)
      state == state
    end

    def last
      history[-2]
    end

    def validate!(state)
      state = state.to_sym
      raise Actor::InvalidState.new(state, self) unless states.include?(state)
    end

    def garbage_collect!
      history.shift while history.size > states.size
    end

    def before_every(&hook)
      pre_hooks << hook
      self
    end

    def after_every(&hook)
      post_hooks << hook
      self
    end

    def add(state, &callback)
      ref = self

      states << state.to_sym
      supervisor.add(state) do
        Fiber.yield until ref.is?(state)
        ref.history << state
        garbage_collect!
        pre_hooks.each do |hook| hook.call(ref) end
        # did a pre_hook prempt this op?
        if ref.is?(state)
          callback.call(ref)
          post_hooks.each do |hook| hook.call(ref) end
        end
      end
      self
    end

    def link!
      supervisor.link!
    end
  end

  class InvalidState < Exception
    def initialize(state, flow)
      super "Actor::state cannot be #{state}, validate states: #{flow.states}"
    end
  end
end