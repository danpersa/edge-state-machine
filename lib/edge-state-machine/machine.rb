module EdgeStateMachine
  class Machine
    attr_accessor :states, :events, :klass, :persisted_variable_name
    attr_reader :name, :initial_state_name

    def initialize(klass, name, &block)
      @klass = klass
      @name = name
      @states = Hash.new
      @events = Hash.new
      instance_eval(&block) if block_given?
    end

    def initial_state(name)
      @initial_state_name = name
    end

    def persisted_to(name)
      @persisted_variable_name = name
    end

    def create_scopes(bool = false)
      @create_scopes = bool
    end

    def create_scopes?
      @create_scopes
    end

    def state(name, &state)
      state = EdgeStateMachine::State.new(name, &state)
      @initial_state_name ||= state.name
      @states[name.to_sym] = state
    end

    def event(name, &transitions)
      @events[name.to_sym] ||= EdgeStateMachine::Event.new(name, self, &transitions)
    end
  end
end