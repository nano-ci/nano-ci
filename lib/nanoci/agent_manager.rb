require 'nanoci/local_agent'

class Nanoci
  class AgentManager
    attr_reader :agents

    def initialize(config)
      @agents = config.agents.map { |ac| LocalAgent.new(ac, config.capabilities) }
    end

    def find_agent(required_agent_capabilities)
      @agents
        .find { |a| a.current_job.nil? }
        .find { |a| a.capabilities.superset(required_agent_capabilities) }
    end
  end
end
