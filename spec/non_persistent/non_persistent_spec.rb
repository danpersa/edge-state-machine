require 'non_persistent/non_persistent_helper'


describe Dice do
  let :dice do
    Dice.new
  end

  it 'should have a current state equals with the initial state' do
    dice.current_state_name.should == :one
  end

  it 'should have an event trigger method' do
    dice.should respond_to :roll
  end

  it 'should change state after the event method is called' do
    dice.roll
    dice.current_state_name.should_not == :one
  end
end


describe User do
  let :user do
    User.new
  end

  it 'should have a current state equals with the initial state' do
    user.current_state_name.should == :pending
  end

  it "should have an event trigger method" do
    user.should respond_to :activate
  end

  it 'should have state verfification methods for each state' do
    user.pending?.should == true
    user.active?.should_not == true
    user.blocked?.should_not == true
  end

  it 'should change state after the event method is called' do
    user.activate
    user.current_state_name.should == :active
  end
end

describe Microwave do
  let :microwave do
    Microwave.new
  end

  it 'should have a current state equals with the initial state' do
    microwave.current_state_name(:microwave).should == :unplugged
  end

  it 'should have an event trigger method' do
    microwave.should respond_to :plug_in
  end

  it 'should have state verfification methods for each state' do
    microwave.unplugged?.should == true
    microwave.plugged?.should_not == true
    microwave.door_opened?.should_not == true
    microwave.door_closed?.should_not == true
    microwave.started_in_grill_mode?.should_not == true
    microwave.started?.should_not == true
  end

  it 'should change state after the event method is called' do
    microwave.plug_in
    microwave.current_state_name(:microwave).should == :plugged
    microwave.plugged?.should == true
  end

  it 'should execute enter state action' do
    microwave.plug_in
  end
end
