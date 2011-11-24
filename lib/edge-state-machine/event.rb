module EdgeStateMachine
  class Event
    attr_reader :name, :success, :timestamp

    def initialize(machine, name, options = {}, &block)
      @machine, @name, @transitions = machine, name, []
      if machine
        machine.klass.send(:define_method, "#{name}!") do |*args|
          machine.fire_event(name, self, true, *args)
        end

        machine.klass.send(:define_method, name.to_s) do |*args|
          machine.fire_event(name, self, false, *args)
        end
      end
      update(options, &block)
    end

    def fire(obj, to_state = nil, *args)
      transitions = @transitions.select { |t| t.from == obj.current_state(@machine ? @machine.name : nil) }
      raise InvalidTransition if transitions.size == 0

      next_state = nil
      transitions.each do |transition|
        next if to_state && !Array(transition.to).include?(to_state)
        if transition.perform(obj)
          next_state = to_state || Array(transition.to).first
          transition.execute(obj, *args)
          break
        end
      end
      # Update timestamps on obj if a timestamp has been defined
      update_event_timestamp(obj, next_state) if timestamp_defined?
      next_state
    end

    def transitions_from_state?(state)
      @transitions.any? { |t| t.from? state }
    end

    def ==(event)
      if event.is_a? Symbol
        name == event
      else
        name == event.name
      end
    end
    
    # Has the timestamp option been specified for this event?
    def timestamp_defined?
      !@timestamp.nil?
    end

    def update(options = {}, &block)
      @success       = options[:success] if options.key?(:success)
      self.timestamp = options[:timestamp] if options[:timestamp]
      instance_eval(&block) if block
      self
    end
    
    # update the timestamp attribute on obj
    def update_event_timestamp(obj, next_state)
      obj.send "#{timestamp_attribute_name(obj, next_state)}=", Time.now
    end
    
    # Set the timestamp attribute.
    # @raise [ArgumentError] timestamp should be either a String, Symbol or true
    def timestamp=(value)
      case value
      when String, Symbol, TrueClass
        @timestamp = value
      else
        raise ArgumentError, "timestamp must be either: true, a String or a Symbol"
      end
    end
    

    private
    
    # Returns the name of the timestamp attribute for this event
    # If the timestamp was simply true it returns the default_timestamp_name
    # otherwise, returns the user-specified timestamp name
    def timestamp_attribute_name(obj, next_state)
      timestamp == true ? default_timestamp_name(obj, next_state) : @timestamp
    end
    
    # If @timestamp is true, try a default timestamp name
    def default_timestamp_name(obj, next_state)
      at_name = "%s_at" % next_state
      on_name = "%s_on" % next_state
      case
      when obj.respond_to?(at_name) then at_name
      when obj.respond_to?(on_name) then on_name
      else
        raise NoMethodError, "Couldn't find a suitable timestamp field for event: #{@name}. 
          Please define #{at_name} or #{on_name} in #{obj.class}"
      end
    end
    

    def transitions(trans_opts)
      Array(trans_opts[:from]).each do |s|
        @transitions << Transition.new(trans_opts.merge({:from => s.to_sym}))
      end
    end
  end
end
