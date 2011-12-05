module EdgeStateMachine
  class Event
    attr_reader :name, :success, :timestamp

    def initialize(name, machine, &transitions)
      @machine = machine
      @name = name
      @transitions = []
      instance_eval(&transitions) if block_given?
    end

    def fire(obj, options = {})
      current_state = obj.current_state(@machine.name)
      transition = @transitions.select{ |t| t.from.include? current_state.name }.first

      raise NoTransitionFound.new("No transition found for event #{@name}") if transition.nil?
      return false unless transition.possible?(obj)

      next_state = @machine.states[transition.find_next_state(obj)]
      raise NoStateFound.new("Invalid state #{transition.to.to_s} for transition.") if next_state.nil?
      transition.execute(obj)

      current_state.execute_action(:exit, obj)
      #klass._previous_state = current_state.name.to_s
      next_state.execute_action(:enter, obj)

      obj.set_current_state(next_state, @machine.name, options)
      true
    end

    private
    def transition(trans_opts)
      @transitions << EdgeStateMachine::Transition.new(trans_opts)
    end
  end
end
