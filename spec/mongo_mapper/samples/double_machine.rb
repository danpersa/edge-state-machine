require 'mongo_mapper'
require 'mongo_mapper/edge-state-machine'

class DoubleMachineMongoMapper
  include MongoMapper::Document
  include MongoMapper::EdgeStateMachine
  
  key :state, String
  key :second_state, String

  state_machine do
    # the machine is automatically named :default
    # the scopes are not created by default
    create_scopes true
    # the persistence instance variable is the default one (:state)
    state :first_state # first one is initial state
    state :second_state
    state :third_state # the user in this state can't sign in

    event :first_move do
      transition :from => :first_state, :to => :second_state, :on_transition => :do_move
    end

    event :second_move do
      transition :from => :second_state, :to => :third_state
    end
  end

  state_machine :second do
    # the scopes are not created by default
    create_scopes true
    # for the second machine we must specify the name of the persistence instance variable
    # so there are no conflicts between the state machines
    persisted_to :second_state
    initial_state :red
    state :blue
    state :green
    state :red

    event :go_blue do
      transition :from => [:red, :green], :to => :blue
    end

    event :go_red do
      transition :from => [:blue, :green], :to => :red, :on_transition => [:turn_off, :color_in_red]
    end

    event :go_green do
      transition :from => [:blue, :red], :to => :green
    end
  end

  def do_move
  end

  def turn_off
  end

  def color_in_red
  end
end