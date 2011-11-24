require 'spec_helper'

class StateTestSubject
  include EdgeStateMachine

  state_machine do
  end
end

def new_state(options={})
  EdgeStateMachine::State.new(@state_name, @options.merge(options))
end

describe EdgeStateMachine::State do

  before do
    @state_name = :astate
    @machine = StateTestSubject.state_machine
    @options = { :crazy_custom_key => "key", :machine => @machine }
  end

  it "should set the name" do
    new_state.name.should == :astate
  end

  it "should set the display_name from name" do
    new_state.display_name.should == "Astate"
  end

  it "should set the display_name from options" do
    new_state(:display => "A State").display_name.should == "A State"
  end

  it "should set the options and expose them as options" do
    @options.delete(:machine)
    new_state.options.should == @options
  end

  it "should be equal to a symbol of the same name" do
    new_state.should == :astate
  end

  it "should be equal with a State with the same name" do
    new_state.should == new_state
  end

  it "should send a message to the record for an action if the action is present as a symbol" do
    state = new_state(:entering => :foo)
    record = mock
    record.should_receive(:foo)
    state.call_action(:entering, record)
  end

  it "should call a proc, passing in the record for an action if the action is present" do
    state = new_state(:entering => Proc.new {|r| r.foobar})

    record = mock
    record.should_receive(:foobar)

    state.call_action(:entering, record)
  end
end