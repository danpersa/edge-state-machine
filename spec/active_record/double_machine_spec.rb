require 'active_record/active_record_helper'

describe DoubleMachineActiveRecord do

  before do
    ActiveRecord::Base.establish_connection(:adapter  => "sqlite3", :database => ":memory:")
    ActiveRecord::Migration.verbose = false
    CreateDoubleMachine.migrate(:up)
  end

  let :double_machine do
    DoubleMachineActiveRecord.create!
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

  context 'persistence ' do
    it 'should create scopes for each state machine' do
      3.times { DoubleMachineActiveRecord.create(:state => 'second_state', :second_state => 'blue') }
      3.times { DoubleMachineActiveRecord.create(:state => 'first_state', :second_state => 'blue') }
      DoubleMachineActiveRecord.first_state.count.should == 3
      DoubleMachineActiveRecord.second_state.count.should == 3
      DoubleMachineActiveRecord.blue.count.should == 6
    end

    it 'should save the state machines in the database' do
      machine = DoubleMachineActiveRecord.create(:state => 'second_state', :second_state => 'blue')
      machine.go_red!
      machine.current_state(:second).should == :red
      machine.red?.should == true

      machine.second_move!
      machine.third_state?.should == true
      machine.current_state.should == :third_state

      loaded_machine = DoubleMachineActiveRecord.find_by_id(machine.id)
      loaded_machine.third_state?.should == true
      loaded_machine.current_state.should == :third_state
    end
  end
end