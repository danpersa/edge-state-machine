require 'mongo_mapper'
require 'mongo_mapper/edge-state-machine'

class MongoMapperOrder
  include MongoMapper::Document
  include MongoMapper::EdgeStateMachine

  key :state, String
  key :order_number, Integer
  key :paid_at, DateTime
  key :prepared_on, DateTime
  key :dispatched_at, DateTime
  key :cancellation_date, Date

  state_machine do
    state :opened
    state :placed
    state :paid
    state :prepared
    state :delivered
    state :cancelled

    # no timestamp col is being specified here - should be ignored
    event :place do
      transition :from => :opened, :to => :placed
    end

    # should set paid_at timestamp
    event :pay do
      transition :from => :placed, :to => :paid
    end

    # should set prepared_on
    event :prepare do
      transition :from => :paid, :to => :prepared
    end

    # should set dispatched_at
    event :deliver do
      transition :from => :prepared, :to => :delivered
    end

    # should set cancellation_date
    event :cancel do
      transition :from => [:placed, :paid, :prepared], :to => :cancelled
    end

    # should raise an exception as there is no timestamp col
    event :reopen do
      transition :from => :cancelled, :to => :opened
    end

  end
end