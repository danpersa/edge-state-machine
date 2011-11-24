module Mongoid
  module EdgeStateMachine
    extend ActiveSupport::Concern

    included do
      include ::EdgeStateMachine
      after_initialize :set_initial_state
      validates_presence_of :state
      validate :state_inclusion
    end

    protected

    def write_state(state_machine, state)
      self.state = state.to_s
      save!
    end

    def read_state(state_machine)
      self.state.to_sym
    end

    def set_initial_state
      self.state ||= self.class.state_machine.initial_state.to_s
    end

    def state_inclusion
      unless self.class.state_machine.states.map{|s| s.name.to_s }.include?(self.state.to_s)
        self.errors.add(:state, :inclusion, :value => self.state)
      end
    end
  end
end

