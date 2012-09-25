require 'mongoid/mongoid_helper'

describe 'mongoid state machine' do

  context 'existing mongo document' do
    before do
      session = Moped::Session.new([ 'localhost:27017' ])
      session.use 'edge-state-machine-test'
      session.drop
    end

    let :light do
      MongoTrafficLight.create!
    end

    it 'should have an initial state' do
      light.off?.should == true
      light.current_state.should == :off
    end

    it 'should go to a valid state on transition' do
      light.reset
      light.red?.should == true
      light.current_state.should == :red

      light.green_on
      light.green?.should == true
      light.current_state.should == :green
    end

    it 'should not persist state on transition' do
      light.reset
      light.current_state.should == :red
      light.reload
      light.state.should == :off
    end

    it 'should persists state on transition' do
      light.reset!
      light.current_state.should == :red
      light.reload
      light.state.should == 'red'
    end

    it 'should initialize the current state when loaded from database' do
      light.reset!
      loaded_light = MongoTrafficLight.find(light.id)
      loaded_light.current_state.should == :red
    end

    it 'should raise error on transition to an invalid state' do
      expect { light.yellow_on }.to raise_error EdgeStateMachine::NoTransitionFound
      light.current_state.should == :off
    end

    it 'should persist state when state is protected on transition' do
      protected_light = MongoProtectedTrafficLight.create!
      protected_light.reset!
      protected_light.current_state.should == :red
      protected_light.reload
      protected_light.state.should == 'red'
    end

    it 'should not validate when try transition with wrong state ' do
      for s in light.class.state_machines[:default].states.keys
        light.state = s
        light.valid?.should == true
      end
      light.state = 'invalid_one'
      light.valid?.should_not == true
    end

    it 'should raise exception when model validation fails on transition' do
      validating_light = MongoValidatingTrafficLight.create!
      expect {validating_light.reset!}.to raise_error Mongoid::Errors::Validations
    end

    it 'should state query method used in a validation condition' do
      validating_light = MongoConditionalValidatingTrafficLight.create!
      #expect {validating_light.reset!}.to raise_error Mongoid::RecordInvalid
      validating_light.off?.should == true
    end

    it 'should reload the model when current state resets' do
      light.reset
      light.red?.should == true
      light.update_attribute(:state, 'green')
      light.reload.green?.should == true # reloaded state should come from database
    end

    describe 'scopes' do
      it 'should be added for each state' do
        MongoTrafficLight.should respond_to(:off)
        MongoTrafficLight.should respond_to(:red)
      end

      it 'should not be added for each state' do
        MongoTrafficLightNoScope.should_not respond_to(:off)
        MongoTrafficLightNoScope.should_not respond_to(:red)
      end

      it 'should behave like scopes' do
        3.times { MongoTrafficLight.create(:state => 'off') }
        3.times { MongoTrafficLight.create(:state => 'red') }
        MongoTrafficLight.off.count.should == 3
        MongoTrafficLight.red.count.should == 3
      end
    end
  end

  context 'new active record' do
    let :light do
      MongoTrafficLight.new
    end

    it 'should have the initial state set' do
      light.current_state.should == :off
    end
  end

  context 'timestamp' do
    before do
      session = Moped::Session.new([ 'localhost:27017' ])
      session.use 'edge-state-machine-test'
      session.drop
    end

    def create_order(state = nil)
      MongoOrder.create! order_number: 234, state: state
    end

    # control case, no timestamp has been set so we should expect default behaviour
    it 'should not raise any exceptions when moving to placed' do
      @order = create_order
      expect { @order.place! }.to_not raise_error
      @order.state.should == 'placed'
    end
  end
end