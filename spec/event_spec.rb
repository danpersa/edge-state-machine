require 'spec_helper'

class ArgumentsTestSubject
  include EdgeStateMachine
  attr_accessor :date

  state_machine do
    state :initial
    state :opened

    event :open do
      transitions :from => :initial, :to => :opened, :on_transition => :update_date
    end
  end

  def update_date(date = Date.today)
    self.date = date
  end
end

def new_event
  @event = EdgeStateMachine::Event.new(nil, @state_name, {:success => @success}) do
    transitions :to => :closed, :from => [:open, :received]
  end
end

describe EdgeStateMachine::Event do

  before do
    @state_name = :close_order
    @success = :success_callback
    @event = EdgeStateMachine::Event.new(nil, @state_name, {:success => @success}) do
      transitions :to => :closed, :from => [:open, :received]
    end
  end

  it "should set the name" do
    @state_name.should == @event.name
  end

  it "should set the success option" do
    @success.should == @event.success
  end

  it "should create StateTransitions" do
    EdgeStateMachine::StateTransition.should_receive(:new).with(:to => :closed, :from => :open)
    EdgeStateMachine::StateTransition.should_receive(:new).with(:to => :closed, :from => :received)
    new_event
  end

  describe "event arguments" do
    it "should pass arguments to transition method" do
      subject = ArgumentsTestSubject.new
      subject.current_state.should == :initial
      subject.open!(Date.strptime('2001-02-03', '%Y-%m-%d'))
      subject.current_state.should == :opened
      subject.date.should == Date.strptime('2001-02-03', '%Y-%m-%d')
    end
  end

  describe "events being fired" do
    it "should raise an EdgeStateMachine::InvalidTransition error if the transitions are empty" do
      event = EdgeStateMachine::Event.new(nil, :event)
      expect {event.fire(nil)}.should raise_error EdgeStateMachine::InvalidTransition
    end

    it "should return the state of the first matching transition it finds" do
      event = EdgeStateMachine::Event.new(nil, :event) do
        transitions :to => :closed, :from => [:open, :received]
      end
      obj = mock
      obj.stub!(:current_state).and_return(:open)
      event.fire(obj).should == :closed
    end
  end
end