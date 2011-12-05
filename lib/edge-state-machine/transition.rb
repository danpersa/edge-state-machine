module EdgeStateMachine
  class Transition
    attr_reader :from, :to, :options

    def initialize(opts)
      @from, @to, @guard, @on_transition = [opts[:from]].flatten, [opts[:to]].flatten, opts[:guard], [opts[:on_transition]].flatten
    end

    def find_next_state(obj)
      # if we have many states we can go but no guard
      if @guard.nil? && @to.size > 1
        raise NoGuardFound.new("There are many possible 'to' states but there is no 'guard' to decide which state to go")
      end
      if @guard
        return execute_action(@guard, obj)
      else
        return @to.first
      end
    end

    def possible?(obj)
      next_state = find_next_state(obj)
      return true if @to.include? next_state
      false
    end

    def execute(obj)
      @on_transition.each do |transition|
        case transition
        when Symbol, String
          obj.send(transition)
        when Proc
          transition.call(obj)
        else
          raise ArgumentError, "You can only pass a Symbol, a String or a Proc to 'on_transition' - got #{transition.class}." unless transition.nil?
        end
      end
    end

    def ==(obj)
      @from == obj.from && @to == obj.to
    end

    private
    def execute_action(action, base)
      case action
      when Symbol, String
        base.send(action)
      when Proc
        action.call(base)
      end
    end
  end
end
