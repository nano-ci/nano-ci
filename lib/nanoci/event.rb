# frozen_string_literal: true

module Nanoci
  # Base class for event loop
  class Event
    # Gets event type
    # @return [Symbol]
    attr_reader :type

    # Gets event data
    # @return [Object] event specific data
    attr_reader :data

    # Initializes new instance of [Event]
    def initialize(type, data = nil)
      @type = type
      @data = data
    end

    def to_s
      "Event <#{type}>"
    end
  end
end
