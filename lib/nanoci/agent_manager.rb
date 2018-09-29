# frozen_string_literal: true

require 'logging'
require 'set'

require 'nanoci/local_agent'

class Nanoci
  # Agent manager controlls access to build agents
  class AgentManager
    attr_reader :agents

    def initialize(config, env)
      @log = Logging.logger[self]

      @agents = config.agents.map do |ac|
        LocalAgent.new(ac, config.capabilities, env)
      end
    end

    def find_agent(required_agent_capabilities)
      @agents.find do |a|
        @log.debug("#{a.name} has capabilities #{a.capabilities}")
        a.capabilities?(required_agent_capabilities) && a.current_job.nil?
      end
    end
  end
end
