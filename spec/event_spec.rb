require 'spec_helper'

class ArgumentsTestSubject
  include EdgeStateMachine
  attr_accessor :date

  state_machine do
    state :initial
    state :opened

    event :open do
      transition :from => :initial, :to => :opened, :on_transition => :update_date
    end
  end

  def update_date(date = Date.today)
    self.date = date
  end
end

def new_event
  @event = EdgeStateMachine::Event.new(@state_name, nil) do
    transition :to => :closed, :from => [:open, :received]
  end
end

describe EdgeStateMachine::Event do

  before do
    @state_name = :close_order
    @success = :success_callback
    @event = EdgeStateMachine::Event.new(@state_name, nil) do
      transition :to => :closed, :from => [:open, :received]
    end
  end

  it 'should set the name' do
    @state_name.should == @event.name
  end

  it 'should create Transitions' do
    EdgeStateMachine::Transition.should_receive(:new).with(:to => :closed, :from => [:open, :received])
    new_event
  end

  describe 'event arguments' do
    it 'should pass arguments to transition method' do
      subject = ArgumentsTestSubject.new
      subject.current_state.should == :initial
      subject.open!
      subject.current_state.should == :opened
    end
  end

  describe 'events being fired' do
    before do
      @machine = mock
      @machine.stub!(:name).and_return(:default)
    end

    it 'should raise an EdgeStateMachine::NoTransitionFound error if the transitions are empty' do
      event = EdgeStateMachine::Event.new(:event, @machine)
      obj = mock
      obj.stub!(:current_state).and_return(:open)
      expect {event.fire(obj)}.to raise_error EdgeStateMachine::NoTransitionFound
    end
  end
end