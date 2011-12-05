require 'edge-state-machine'

class User
  include EdgeStateMachine

  state_machine do
    state :pending # first one is initial state
    state :active
    state :blocked # the user in this state can't sign in

    event :activate do
      transition :from => [:pending], :to => :active, :on_transition => :do_activate
    end

    event :block do
      transition :from => [:pending, :active], :to => :blocked
    end
  end

  def do_activate
    # p 'do activate'
  end
end