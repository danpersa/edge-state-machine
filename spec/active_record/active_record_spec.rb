require 'active_record/active_record_helper'

describe "active record state machine" do

  context "existing active record" do
    before do
      ActiveRecord::Base.establish_connection(:adapter  => "sqlite3", :database => ":memory:")
      ActiveRecord::Migration.verbose = false
      CreateTrafficLights.migrate(:up)
      @light = TrafficLight.create!
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
      protected_light = ProtectedTrafficLight.create!
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
      validating_light = ValidatingTrafficLight.create!
      expect {validating_light.reset!}.should raise_error ActiveRecord::RecordInvalid
      validating_light.off?.should == true
    end

    #it "should state query method used in a validation condition" do
      #validating_light = ConditionalValidatingTrafficLight.create!
      #expect {validating_light.reset!}.should raise_error ActiveRecord::RecordInvalid
      #validating_light.off?.should == true
    #end

    it "should reload the model when current state resets" do
      @light.reset
      @light.red?.should == true
      @light.update_attribute(:state, 'green')
      @light.reload.green?.should == false # reloaded state should come from instance variable not from database
      # because the state can be changed without persist
    end
  end

  context "new active record" do
    before do
      @light = TrafficLight.new
    end

    it "should have the initial state set" do
      @light.current_state.should == :off
    end
  end

  context "timestamp" do
    before do
      ActiveRecord::Base.establish_connection(:adapter  => "sqlite3", :database => ":memory:")
      ActiveRecord::Migration.verbose = false
      CreateOrders.migrate(:up)
    end

    def create_order(state = nil)
      Order.create! order_number: 234, state: state
    end

    # control case, no timestamp has been set so we should expect default behaviour
    it "should not raise any exceptions when moving to placed" do
      @order = create_order
      expect { @order.place! }.should_not raise_error
      @order.state.should == "placed"
    end

    it "should set paid_at when moving to paid" do
      @order = create_order(:placed)
      @order.pay!
      @order.reload
      @order.paid_at.should_not be_nil
    end

    it "should set prepared_on when moving to prepared" do
      @order = create_order(:paid)
      @order.prepare!
      @order.reload
      @order.prepared_on.should_not be_nil
    end

    it "should set dispatched_at when moving to delivered" do
      @order = create_order(:prepared)
      @order.deliver!
      @order.reload
      @order.dispatched_at.should_not be_nil
    end

    it "should set cancellation_date when moving to cancelled" do
      @order = create_order(:placed)
      @order.cancel!
      @order.reload
      @order.cancellation_date.should_not be_nil
    end

    it "should raise an exception as there is no attribute when moving to reopened" do
      @order = create_order(:cancelled)
      expect { @order.re_open! }.should raise_error NoMethodError
      @order.reload
    end

    it "should raise an exception when passing an invalid value to timestamp options" do
      expect {
        class Order < ActiveRecord::Base
          include ActiveRecord::EdgeStateMachine
          state_machine do
            event :replace, timestamp: 1 do
              transitions :from => :prepared, :to => :placed
            end
          end
        end
      }.should raise_error ArgumentError
    end

  end
end
