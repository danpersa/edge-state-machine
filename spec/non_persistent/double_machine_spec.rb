require 'non_persistent/non_persistent_helper'

describe DoubleMachine do

  let :double_machine do
    DoubleMachine.new
  end

  it 'should have a current state equals with the initial state for each machine' do
    double_machine.current_state.should == :first_state
    double_machine.current_state(:second).should == :red
  end

  it 'should have the corresponding methods for verifying the states' do
    double_machine.first_state?.should == true
    double_machine.second_state?.should == false
    double_machine.red?.should == true
    double_machine.green?.should == false
  end

  it 'should trigger events from the state machines' do
    double_machine.first_move
    double_machine.current_state.should == :second_state
    double_machine.second_state?.should == true

    double_machine.go_green
    double_machine.current_state(:second).should == :green
    double_machine.green?.should == true

    double_machine.second_move
    double_machine.current_state.should == :third_state
    double_machine.third_state?.should == true
  end

  it 'should execute the on_transition method' do
    double_machine.should_receive :do_move
    double_machine.first_move
    double_machine.go_green

    double_machine.should_receive :turn_off
    double_machine.should_receive :color_in_red
    double_machine.go_red
  end
end