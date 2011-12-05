require "edge-state-machine/event"
require "edge-state-machine/machine"
require "edge-state-machine/state"
require "edge-state-machine/transition"
require "edge-state-machine/exception"
require "edge-state-machine/version"

module EdgeStateMachine

  def self.included(base)
    base.extend(ClassMethods)
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def inherited(klass)
      super
      klass.state_machines = state_machines
    end

    def state_machines
      @state_machines ||= {}
    end

    def state_machines=(value)
      @state_machines = value ? value.dup : nil
    end

    def state_machine(name = :default, &block)
      machine = Machine.new(self, name, &block)
      state_machines[name] ||= machine

      machine.persisted_variable_name ||= :state

      machine.states.values.each do |state|
        state_name = state.name
        define_method "#{state_name}?" do
          state_name == current_state(name).name
        end
        add_scope(state, name) if machine.create_scopes?
      end

      machine.events.keys.each do |key|
        define_method "#{key}" do
          fire_event(machine.name, {:save => false}, key)
        end

        define_method "#{key}!" do
          fire_event(machine.name, {:save => true}, key)
        end
      end
    end
  end

  module InstanceMethods
    attr_writer :current_state

    def initial_state_name(name = :default)
      machine = self.class.state_machines[name]
      return machine.initial_state_name
    end

    def current_state(name = :default)
      @current_states ||= {}
      machine = self.class.state_machines[name]
      if (respond_to? :load_from_persistence)
        @current_states[name] ||= self.class.state_machines[name].states[load_from_persistence(name).to_sym]
      end
      @current_states[name] ||= machine.states[machine.initial_state_name]
    end

    def current_state_name(name = :default)
      current_state(name).name
    end

    def fire_event(name = :default, options = {}, event_name)
      machine = self.class.state_machines[name]
      event = machine.events[event_name]
      raise Stateflow::NoEventFound.new("No event matches #{event_name}") if event.nil?
      event.fire(self, options)
    end

    def set_current_state(new_state, machine_name = :default, options = {})
      save_to_persistence(new_state.name.to_s, machine_name, options) if self.respond_to? :save_to_persistence
      @current_states[machine_name] = new_state
    end
  end
end
