# frozen_string_literal: true

module Nanoci
  # A job is a collection of tasks to run actions and produce artifacts
  class Job
    # @return [Symbol]
    attr_reader :tag

    # @return [Proc]
    attr_reader :body

    attr_reader :state

    def state=(next_state)
      raise "invalid state #{next_state}" unless State::VALUES.include? next_state

      @state = next_state
    end

    # Initializes new instance of [Job]
    # @param src [Hash]
    def initialize(src)
      @tag = src[:tag]
      @body = src[:block]
      @state = State::IDLE
    end
  end
end
