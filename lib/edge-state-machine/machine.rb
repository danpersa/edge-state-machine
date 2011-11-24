module EdgeStateMachine
  class Machine
    attr_writer :initial_state
    attr_accessor :states, :events, :state_index
    attr_reader :klass, :name, :auto_scopes

    def initialize(klass, name, options = {}, &block)
      @klass, @name, @states, @state_index, @events = klass, name, [], {}, {}
      update(options, &block)
    end

    def initial_state
      @initial_state ||= (states.first ? states.first.name : nil)
    end

    def update(options = {}, &block)
      @initial_state = options[:initial] if options.key?(:initial)
      @auto_scopes = options[:auto_scopes]
      instance_eval(&block) if block
      include_scopes if @auto_scopes && defined?(ActiveRecord::Base) && @klass < ActiveRecord::Base
      self
    end

    def fire_event(event, record, persist, *args)
      state_index[record.current_state(@name)].call_action(:exit, record)
      if new_state = @events[event].fire(record, nil, *args)
        state_index[new_state].call_action(:enter, record)

        if record.respond_to?(event_fired_callback)
          record.send(event_fired_callback, record.current_state, new_state, event)
        end

        record.current_state(@name, new_state, persist)
        record.send(@events[event].success) if @events[event].success
        true
      else
        if record.respond_to?(event_failed_callback)
          record.send(event_failed_callback, event)
        end

        false
      end
    end

    def states_for_select
      states.map { |st| [st.display_name, st.name.to_s] }
    end

    def events_for(state)
      events = @events.values.select { |event| event.transitions_from_state?(state) }
      events.map! { |event| event.name }
    end

    def current_state_variable
      "@#{@name}_current_state"
    end

    private

    def state(name, options = {})
      @states << (state_index[name] ||= State.new(name, :machine => self)).update(options)
    end

    def event(name, options = {}, &block)
      (@events[name] ||= Event.new(self, name)).update(options, &block)
    end

    def event_fired_callback
      @event_fired_callback ||= (@name == :default ? '' : "#{@name}_") + 'event_fired'
    end

    def event_failed_callback
      @event_failed_callback ||= (@name == :default ? '' : "#{@name}_") + 'event_failed'
    end

    def include_scopes
      @states.each do |state|
        state_name = state.name.to_s
        raise InvalidMethodOverride if @klass.respond_to?(state_name)
        @klass.scope state_name, @klass.where(:state => state_name)
      end
    end
  end
end

