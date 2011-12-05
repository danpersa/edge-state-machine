module EdgeStateMachine
  class InvalidTransition     < StandardError; end
  class InvalidMethodOverride < StandardError; end
  class NoTransitionFound < Exception; end
  class NoStateFound < Exception; end
  class NoEventFound < Exception; end
  class NoGuardFound < Exception; end
end