require 'set'

require 'nanoci/local_agent'

class Nanoci
  class AgentManager
    attr_reader :agents

    def initialize(config, env)
      @agents = config.agents.map { |ac| LocalAgent.new(ac, config.capabilities, env) }
    end

    def find_agent(required_agent_capabilities)
      @agents.find do |a|
        a.capabilities?(required_agent_capabilities) && a.current_job.nil?
      end
    end
  end
end
