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
      transitions :from => :parked, :to => :running, :on_transition => :start_engine
    end

    event :start_driving do
      transitions :from => :parked, :to => :driving, :on_transition => [:start_engine, :loosen_handbrake, :push_gas_pedal]
    end
  end

  def event_fired(current_state, new_state, event)
  end

  %w!start_engine loosen_handbrake push_gas_pedal!.each do |m|
    define_method(m){}
  end
end

def new_state(options={})
  EdgeStateMachine::State.new(@state_name, @options.merge(options))
end

describe EdgeStateMachine::State do

  describe "general methods" do
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

    it "should send a message to the record for an action if the action is present as a string" do
      state = new_state(:entering => "foo")

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

  describe "state transitions" do
    it "should set from, to, and opts attr readers" do
      opts = {:from => "foo", :to => "bar", :guard => "g"}
      st = EdgeStateMachine::StateTransition.new(opts)

      st.from.should == opts[:from]
      st.to.should == opts[:to]
      st.options.should == opts
    end

    it "should pass equality check if from and to are the same" do
      opts = {:from => "foo", :to => "bar", :guard => "g"}
      st = EdgeStateMachine::StateTransition.new(opts)
      obj = EdgeStateMachine::StateTransition.new(opts)
      obj.should == st
    end

    it "should fail equality check if from are not the same" do
      opts = {:from => "foo", :to => "bar", :guard => "g"}
      st = EdgeStateMachine::StateTransition.new(opts)
      obj = EdgeStateMachine::StateTransition.new(opts.merge({:from => "blah"}))
      obj.should_not == st
    end

    it "should fail equality check if to are not the same" do
      opts = {:from => "foo", :to => "bar", :guard => "g"}
      st = EdgeStateMachine::StateTransition.new(opts)
      obj = EdgeStateMachine::StateTransition.new(opts.merge({:to => "blah"}))
      obj.should_not == st
    end
  end

  describe "state transition callbacks" do
    before do
      @car = Car.new
    end

    it "should execute callback defined via 'on_transition'" do
      @car.should_receive(:start_engine)
      @car.turn_key!
    end

    it "should execute multiple callbacks defined via 'on_transition' in the same order they were defined" do
      @car.should_receive(:start_engine).ordered
      @car.should_receive(:loosen_handbrake).ordered
      @car.should_receive(:push_gas_pedal).ordered
      @car.start_driving!
    end

    it "should pass event when calling event_fired_callback" do
      @car.should_receive(:event_fired).with(:parked, :driving, :start_driving)
      @car.start_driving!
    end
  end

  describe "state transition guard check" do
    it "should return true of there is no guard" do
      opts = {:from => "foo", :to => "bar"}
      st = EdgeStateMachine::StateTransition.new(opts)
      st.perform(nil).should == true
    end

    it "should call the method on the object if guard is a symbol" do
      opts = {:from => "foo", :to => "bar", :guard => :test_guard}
      st = EdgeStateMachine::StateTransition.new(opts)

      obj = mock
      obj.should_receive(:test_guard)

      st.perform(obj)
    end

    it "should call the method on the object if guard is a string" do
      opts = {:from => "foo", :to => "bar", :guard => "test_guard"}
      st = EdgeStateMachine::StateTransition.new(opts)

      obj = mock
      obj.should_receive(:test_guard)

      st.perform(obj)
    end

    it "should call the proc passing the object if the guard is a proc" do
      opts = {:from => "foo", :to => "bar", :guard => Proc.new {|o| o.test_guard}}
      st = EdgeStateMachine::StateTransition.new(opts)

      obj = mock
      obj.should_receive(:test_guard)

      st.perform(obj)
    end
  end
end