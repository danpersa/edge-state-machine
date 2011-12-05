require 'edge-state-machine'

class Dice
  include EdgeStateMachine

  state_machine do
    state :one
    state :two
    state :three
    state :four
    state :five
    state :six

    event :roll do
      transition :from => [:one, :two, :three, :four, :five, :six],
                 :to => [:one, :two, :three, :four, :five, :six],
                 :guard => :roll_result,
                 :on_transition => :display_dice_rolling_animation
    end
  end

  def roll_result
    # return one of the states, except the initial state
    [:two, :three, :four, :five, :six][Random.rand(4)]
  end

  def display_dice_rolling_animation
    # draw the new position of the dice
    # p 'display dice'
  end
end