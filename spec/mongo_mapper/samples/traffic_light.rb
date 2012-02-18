require 'mongo_mapper'
require 'mongo_mapper/edge-state-machine'

class MongoMapperTrafficLight
  include MongoMapper::Document
  include MongoMapper::EdgeStateMachine

  key :state, String

  state_machine do
    create_scopes true
    persisted_to :state
    state :off

    state :red
    state :green
    state :yellow

    event :red_on do
      transition :to => :red, :from => [:yellow]
    end

    event :green_on do
      transition :to => :green, :from => [:red]
    end

    event :yellow_on do
      transition :to => :yellow, :from => [:green]
    end

    event :reset do
      transition :to => :red, :from => [:off]
    end
  end
end

class MongoMapperProtectedTrafficLight < MongoMapperTrafficLight
  attr_protected :state
end

class MongoMapperValidatingTrafficLight < MongoMapperTrafficLight
  validate {|t| errors.add(:base, 'This TrafficLight will never validate after creation') unless t.new_record? }
end

class MongoMapperConditionalValidatingTrafficLight < MongoMapperTrafficLight
  validates :name, :presence => true, :length  => { :within => 20..40 }, :confirmation => true, :if => :red?
end

class MongoMapperTrafficLightNoScope
  include MongoMapper::Document
  include MongoMapper::EdgeStateMachine

  key :state, String

  state_machine do
    persisted_to :state
    state :off

    state :red
    state :green
    state :yellow

    event :red_on do
      transition :to => :red, :from => [:yellow]
    end

    event :green_on do
      transition :to => :green, :from => [:red]
    end

    event :yellow_on do
      transition :to => :yellow, :from => [:green]
    end

    event :reset do
      transition :to => :red, :from => [:off]
    end
  end
end