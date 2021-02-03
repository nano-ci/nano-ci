# frozen_string_literal: true

module Nanoci
  # Class representing test execution result
  class Test
    module State
      PASS = :pass
      FAIL = :fail
      INCONCLUSIVE = :inconclusive
      SKIP = :skip
    end

    # Gets test tag
    # @return [Symbol]
    attr_reader :tag

    # Gets test state
    # @return [Symbol]
    attr_reader :state

    def initialize(tag, state)
      @tag = tag
      @state = state
    end

    def memento
      {
        tag: tag,
        state: state
      }
    end
  end
end
