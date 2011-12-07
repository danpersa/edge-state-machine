require 'spec_helper'

class MachineTestSubject
  include EdgeStateMachine

  state_machine do
    state :open
    state :closed
  end

  state_machine do
    initial_state :open

    event :shutdown do
      transition :from => :open, :to => :closed
    end

    event :timeout do
      transition :from => :open, :to => :closed
    end
  end

  state_machine :extra do
    initial_state :bar
  end
end

describe EdgeStateMachine::Machine do

  it 'should allow reuse of existing machines' do
    MachineTestSubject.state_machines.size.should == 2
  end

  it 'should set #initial_state_name from initial_state method' do
    MachineTestSubject.state_machines[:extra].initial_state_name.should == :bar
  end

  it 'should access non-default state machine' do
    MachineTestSubject.state_machines[:extra].class.should == EdgeStateMachine::Machine
  end
end
