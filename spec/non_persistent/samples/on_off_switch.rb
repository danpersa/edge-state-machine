require 'edge-state-machine'

class OnOffSwitch
  include EdgeStateMachine

  state_machine :on_off do

    initial_state :off
    state :on do
      enter :turn_on_the_light
    end
    state :off do
      enter :turn_off_the_light
    end

    event :press_on do
      transition :from => :off, :to => :on
    end

    event :press_off do
      transition :from => :on, :to => :off
    end
  end

  def turn_on_the_light
  end

  def turn_off_the_light
  end
end

# this is a different implementation of the switch state machine, using a guard
class DigitalOnOffSwitch
  include EdgeStateMachine

  # this state machine has the :default name
  state_machine do
    # the initial state is the first defined state, in this case :off
    state :off do
      enter :turn_off_the_light
    end

    state :on do
      enter :turn_on_the_light
    end

    event :press do
      transition :from => [:on, :off], :to => [:on, :off], :guard => :change_state
    end
  end

  def change_state
    return :on if current_state == :off
    return :off
  end

  def turn_on_the_light
  end

  def turn_off_the_light
  end
end