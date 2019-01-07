# frozen_string_literal: true

module Nanoci
  # Base class for event loop
  class Event
    private

    # Initializes new instance of [Event]
    # @note [Event] is supposed to be sub-classed. Direct usage of [Event] is invalid
    def initialize; end
  end
end
