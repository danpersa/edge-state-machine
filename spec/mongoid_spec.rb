require 'mongoid_helper'

class MongoTrafficLight
  include Mongoid::Document
  include Mongoid::EdgeStateMachine
  field :state

  state_machine do
    state :off

    state :red
    state :green
    state :yellow

    event :red_on do
      transitions :to => :red, :from => [:yellow]
    end

    event :green_on do
      transitions :to => :green, :from => [:red]
    end

    event :yellow_on do
      transitions :to => :yellow, :from => [:green]
    end

    event :reset do
      transitions :to => :red, :from => [:off]
    end
  end
end

class MongoProtectedTrafficLight < MongoTrafficLight
  attr_protected :state
end

class MongoValidatingTrafficLight < MongoTrafficLight
  validate {|t| errors.add(:base, 'This TrafficLight will never validate after creation') unless t.new_record? }
end

describe "mongoid state machine" do

  before do
    Mongoid.master.collections.reject { |c| c.name =~ /^system\./ }.each(&:drop)
    @light = MongoTrafficLight.create!
  end

  it "should have an initial state" do
    @light.off?.should == true
    @light.current_state.should == :off
  end

  it "should go to a valid state on transition" do
    @light.reset
    @light.red?.should == true
    @light.current_state.should == :red

    @light.green_on
    @light.green?.should == true
    @light.current_state.should == :green
  end

  it "should not persist state on transition" do
    @light.reset
    @light.current_state.should == :red
    @light.reload
    @light.state.should == "off"
  end

  it "should persists state on transition" do
    @light.reset!
    @light.current_state.should == :red
    @light.reload
    @light.state.should == "red"
  end

  it "should raise error on transition to an invalid state" do
    expect { @light.yellow_on }.should raise_error EdgeStateMachine::InvalidTransition
    @light.current_state.should == :off
  end

  it "should persist state when state is protected on transition" do
    protected_light = MongoProtectedTrafficLight.create!
    protected_light.reset!
    protected_light.current_state.should == :red
    protected_light.reload
    protected_light.state.should == "red"
  end

  it "should not validate when try transition with wrong state " do
    for s in @light.class.state_machine.states
      @light.state = s.name
      @light.valid?.should == true
    end
    @light.state = "invalid_one"
    @light.valid?.should_not == true
  end

  it "should raise exception when model validation fails on transition" do
    validating_light = MongoValidatingTrafficLight.create!
    expect {validating_light.reset!}.should raise_error Mongoid::Errors::Validations
  end
end