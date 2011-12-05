require 'spec_helper'

class StateTestSubject
  include EdgeStateMachine

  state_machine do
  end
end

class Car
  include EdgeStateMachine

  state_machine do
    state :parked
    state :running
    state :driving

    event :turn_key do
      transition :from => :parked, :to => :running, :on_transition => :start_engine
    end

    event :start_driving do
      transition :from => :parked, :to => :driving, :on_transition => [:start_engine, :loosen_handbrake, :push_gas_pedal]
    end
  end

  def event_fired(current_state, new_state, event)
  end

  %w!start_engine loosen_handbrake push_gas_pedal!.each do |m|
    define_method(m){}
  end
end

def new_state(options={})
  EdgeStateMachine::State.new(@state_name)
end

describe EdgeStateMachine::State do

  before do
    @state_name = :astate
    @machine = StateTestSubject.state_machine
  end

  it "should set the name" do
    new_state.name.should == :astate
  end

  it "should set the display_name from name" do
    new_state.display_name.should == "Astate"
  end

  it "should set the display_name from method" do
    state = new_state
    state.use_display_name('A State')
    state.display_name.should == 'A State'
  end

  it "should set the options and expose them as options" do
    new_state.options.should_not == nil
  end

  it "should be equal to a symbol of the same name" do
    new_state.should == :astate
  end

  it "should be equal with a State with the same name" do
    new_state.should == new_state
  end

  it "should send a message to the record for an action if the action is present as a symbol" do
    state = new_state
    state.enter :foo
    
    record = mock
    record.should_receive(:foo)
    
    state.execute_action(:enter, record)
  end

  it "should send a message to the record for an action if the action is present as a string" do
    state = new_state
    state.enter "foo"

    record = mock
    record.should_receive(:foo)

    state.execute_action(:enter, record)
  end

  it "should call a proc, passing in the record for an action if the action is present" do
    state = new_state
    state.exit Proc.new {|r| r.foobar}

    record = mock
    record.should_receive(:foobar)

    state.execute_action(:exit, record)
  end
end