module ActiveRecord
  module EdgeStateMachine
    extend ActiveSupport::Concern

    included do
      include ::EdgeStateMachine
      after_initialize :set_initial_state
      validate :state_variables_presence
      validate :state_inclusion
    end

    # The optional options argument is passed to find when reloading so you may
    # do e.g. record.reload(:lock => true) to reload the same record with an
    # exclusive row lock.
    def reload(options = nil)
      super.tap do
        @current_states = {}
      end
    end

    protected

    def load_from_persistence(machine_name)
      machine = self.class.state_machines[machine_name]
      send machine.persisted_variable_name.to_s
    end

    def save_to_persistence(new_state, machine_name, options = {})
      machine = self.class.state_machines[machine_name]
      send("#{machine.persisted_variable_name}=".to_sym, new_state)
      save! if options[:save]
    end

    def set_initial_state
      # set the initial state for each state machine in this class
      self.class.state_machines.keys.each do |machine_name|
        machine = self.class.state_machines[machine_name]

        if persisted_variable_value(machine.persisted_variable_name).blank?
          if load_from_persistence(machine_name)
            send("#{machine.persisted_variable_name}=".to_sym, load_from_persistence(machine_name))
          else
            send("#{machine.persisted_variable_name}=".to_sym, machine.initial_state_name)
          end
        end
      end
    end

    def persisted_variable_value(name)
      send(name.to_s)
    end

    def state_variables_presence
      # validate that state is in the right set of values
      self.class.state_machines.keys.each do |machine_name|
        machine = self.class.state_machines[machine_name]
        validates_presence_of machine.persisted_variable_name.to_sym
      end
    end

    def state_inclusion
      # validate that state is in the right set of values
      self.class.state_machines.keys.each do |machine_name|
        machine = self.class.state_machines[machine_name]
        unless machine.states.keys.include?(persisted_variable_value(machine.persisted_variable_name).to_sym)
          self.errors.add(machine.persisted_variable_name.to_sym, :inclusion, :value => persisted_variable_value(machine.persisted_variable_name))
        end
      end
    end

    module ClassMethods
      def add_scope(state, machine_name)
        machine = state_machines[machine_name]
        scope state.name, -> { where(machine.persisted_variable_name.to_sym => state.name.to_s) }
      end
    end
  end
end

