class Nanoci
  class BuildJob
    attr_accessor :definition
    attr_accessor :state

    def initialize(definition)
      @definition = definition
    end

    def required_agent_capabilities
      definition.required_agent_capabilities
    end
  end
end
