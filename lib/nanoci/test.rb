class Nanoci
  class Test
    module State
      PASS = :pass
      FAIL = :fail
      INCONCLUSIVE = :inconclusive
      SKIP = :skip
    end

    attr_reader :tag
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
