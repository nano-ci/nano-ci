require 'nanoci/build'

class Nanoci
  class BuildJob
    attr_accessor :definition
    attr_accessor :state

    def tag
      definition.tag
    end

    def initialize(definition)
      @definition = definition
      @state = Build::State::UNKNOWN
    end

    def required_agent_capabilities
      definition.required_agent_capabilities
    end

    def memento
      {
        tag: tag,
        state: Build::State.to_sym(state)
      }
    end
  end
end
