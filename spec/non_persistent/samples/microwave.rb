require 'edge-state-machine'

class Microwave
  include EdgeStateMachine

  state_machine :microwave do  # name should be optional, if the name is not present, it should have a default name
                               # we give state machines names, so we can pun many machines inside a class
    initial_state :unplugged # initial state should be optional, if the initial state is not present, the initial state will be the first defined state

    state :plugged

    state :unplugged

    state :door_opened do
      enter :light_on            # enter should be executed on entering the state
      exit  :light_off           # exit method should be executed on exiting the state
    end

    state :door_closed

    state :started_in_grill_mode do
      enter lambda { |t| p "Entering hate" }   # should have support for Procs
      exit  :grill_off
    end

    state :started do
      enter :microwaves_on
      exit  :microwaves_off
    end

    event :plug_in do
      transition :from => :unplugged, :to => :plugged
    end

    event :open_door do
      transition :from => :plugged, :to => :door_opened
    end

    event :close_door do
      transition :from => :door_opened, :to => :door_closed, :on_transition => :put_food_in_the_microwave # we can put many actions in an Array for the on_transition parameter
    end

    event :start do
      transition :from => :door_closed, :to => [:started, :started_in_grill_mode], :on_transition => :start_spinning_the_food, :guard => :grill_button_pressed?    # the method grill_button_pressed? should choose the next state
    end

    event :stop do
      transition :from => [:started, :started_in_grill_mode], :to => :door_closed
    end
  end

  def light_on
    p 'light on'
  end
end