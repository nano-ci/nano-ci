# frozen_string_literal: true

require 'concurrent'
require 'logging'
require 'set'

module Nanoci
  # Agent manager controlls access to build agents
  class AgentManager
    attr_reader :agents

    # Initializes new instance of [AgentManager]
    def initialize
      @log = Logging.logger[self]
      @agents = []
      @agent_status_check_interval = 5 * 60
      @agent_status_timeout = 5 * 60

      @timer = Concurrent::TimerTask.new(execution_interval: @agent_status_check_interval) do
        check_agents
      end
    end

    # returns agent with specified tag
    # @param tag [Symbol]
    # @return [Agent]
    def get_agent(tag)
      agents.select { |a| a.tag == tag }.first
    end

    def find_agent(required_agent_capabilities)
      @agents.find do |a|
        @log.debug("#{a.name} has capabilities #{a.capabilities}")
        a.capabilities?(required_agent_capabilities) && a.current_job.nil?
      end
    end

    # Adds a new agent to the agents pool
    # @param agent [Agent]
    # @return [void]
    def add_agent(agent)
      raise "agent with tag #{agent.tag} exists in pool" unless get_agent(agent.tag).nil?
      @agents.push(agent)
      return
    end

    # Removes an agent from the agents pool
    # @param agent [Agent]
    # @return [void]
    def remove_agent(agent)
      raise "agent with tag #{agent.tag} does not exist in pool" if get_agent(agent.tag).nil?
      @agents.delete(agent)
    end

    private

    def check_agents
      @agents
        .select { |x| Time.now.utc - x.status_timestamp > @agent_status_timeout }
        .each { |x| remove_agent(x) }
    end
  end
end
