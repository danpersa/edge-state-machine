require 'non_persistent/non_persistent_helper'

describe OnOffSwitch do

  let :on_off_switch do
    OnOffSwitch.new
  end

  it 'should have a current state equals with the initial state' do
    on_off_switch.current_state(:on_off).should == :off
  end

  it 'should change state after the event method is called' do
    on_off_switch.press_on
    on_off_switch.current_state(:on_off).should == :on
    on_off_switch.on?.should == true
  end

  it 'should execute the enter state action' do
    on_off_switch.should_receive(:turn_on_the_light)
    on_off_switch.press_on

    on_off_switch.should_receive(:turn_off_the_light)
    on_off_switch.press_off
  end
end

describe DigitalOnOffSwitch do

  let :on_off_switch do
    DigitalOnOffSwitch.new
  end

  it 'should have a current state equals with the initial state' do
    on_off_switch.current_state.should == :off
  end

  it 'should change state after the event method is called' do
    on_off_switch.press
    on_off_switch.current_state.should == :on
    on_off_switch.on?.should == true
  end

  it 'should execute the enter state action' do
    on_off_switch.should_receive(:turn_on_the_light)
    on_off_switch.press

    on_off_switch.should_receive(:turn_off_the_light)
    on_off_switch.press
  end
end