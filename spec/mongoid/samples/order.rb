require 'mongoid'
require 'mongoid/edge-state-machine'

class MongoOrder
  include Mongoid::Document
  include Mongoid::EdgeStateMachine

  field :state, :type => String
  field :order_number, :type => Integer
  field :paid_at, :type => DateTime
  field :prepared_on, :type => DateTime
  field :dispatched_at, :type => DateTime
  field :cancellation_date, :type => Date

  state_machine do
    state :opened
    state :placed
    state :paid
    state :prepared
    state :delivered
    state :cancelled

    # no timestamp col is being specified here - should be ignored
    event :place do
      transitions :from => :opened, :to => :placed
    end

    # should set paid_at timestamp
    event :pay, :timestamp => true do
      transitions :from => :placed, :to => :paid
    end

    # should set prepared_on
    event :prepare, :timestamp => true do
      transitions :from => :paid, :to => :prepared
    end

    # should set dispatched_at
    event :deliver, :timestamp => "dispatched_at" do
      transitions :from => :prepared, :to => :delivered
    end

    # should set cancellation_date
    event :cancel, :timestamp => :cancellation_date do
      transitions :from => [:placed, :paid, :prepared], :to => :cancelled
    end

    # should raise an exception as there is no timestamp col
    event :reopen, :timestamp => true do
      transitions :from => :cancelled, :to => :opened
    end

  end
end