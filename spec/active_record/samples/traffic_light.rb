require 'active_record'
require 'active_record/edge-state-machine'

ActiveRecord::Base.establish_connection(:adapter  => "sqlite3", :database => ":memory:")

class TrafficLight < ActiveRecord::Base
  include ActiveRecord::EdgeStateMachine

  state_machine do
    state :off

    state :red
    state :green
    state :yellow

    event :red_on do
      transitions :to => :red, :from => [:yellow]
    end

    event :green_on do
      transitions :to => :green, :from => [:red]
    end

    event :yellow_on do
      transitions :to => :yellow, :from => [:green]
    end

    event :reset do
      transitions :to => :red, :from => [:off]
    end
  end
end

class ProtectedTrafficLight < TrafficLight
  attr_protected :state
end

class ValidatingTrafficLight < TrafficLight
  validate {|t| errors.add(:base, 'This TrafficLight will never validate after creation') unless t.new_record? }
end

class ConditionalValidatingTrafficLight < TrafficLight
  validates :name, :presence => true, :length  => { :within => 20..40 }, :confirmation => true, :if => :red?
end