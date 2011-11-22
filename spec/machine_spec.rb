require 'spec_helper'

class MachineTestSubject
  include EdgeStateMachine

  state_machine do
    state :open
    state :closed
  end

  state_machine :initial => :foo do
    event :shutdown do
      transitions :from => :open, :to => :closed
    end

    event :timeout do
      transitions :from => :open, :to => :closed
    end
  end

  state_machine :extra, :initial => :bar do
  end
end

describe EdgeStateMachine::Machine do

  it 'should allow reuse of existing machines' do
    MachineTestSubject.state_machines.size.should == 2
  end

  it "should set #initial_state from :initial option" do
    MachineTestSubject.state_machine(:extra).initial_state.should == :bar
  end

  it "should accesse non-default state machine" do
    MachineTestSubject.state_machine(:extra).class.should == EdgeStateMachine::Machine
  end

  it "should find event for given state" do
    events = MachineTestSubject.state_machine.events_for(:open)
    events.should be_include(:shutdown)
    events.should be_include(:timeout)
  end
end
