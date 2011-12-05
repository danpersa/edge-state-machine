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