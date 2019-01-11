# frozen_string_literal: true

require 'nanoci/mixins/logger'
require 'nanoci/remote_agent'
require 'nanoci/remote/agent_manager_services_pb'
require 'nanoci/remote/report_agent_status_message_pb'

module Nanoci
  module Remote
    # Implementation of RPC service AgentManager
    class AgentManagerServiceImpl < AgentManager::Service
      include Mixins::Logger

      # Gets an [AgentManager]
      # @return [Nanoci::AgentManager]
      attr_reader :agent_manager

      def initialize(agent_manager)
        @agent_manager = agent_manager
      end

      # Report remote agent status and capabilities
      # @param report_agent_status_request [ReportAgentStatusRequest]
      # @param _call [Object]
      def report_agent_status(report_agent_status_request, _call)
        tag = report_agent_status_request.tag.to_sym
        status = report_agent_status_request.status
        capabilities = report_agent_status_request.capabilities.map { |x| [x.to_sym, true] }.to_h
        agent = get_agent(tag)
        agent.status = status
        agent.capabilities = capabilities
        ReportAgentStatusResponse.new
      end

      private

      # Gets an agent from agent manager.
      # It creates a new [Nanoci::RemoteAgent] if agent does not exist.
      # @param tag [Symbol]
      # @return [Nanoci::Agent]
      def get_agent(tag)
        agent = agent_manager.get_agent(tag)
        if agent.nil?
          agent = RemoteAgent.new(tag, capabilities)
          agent_manager.add_agent(agent)
        end

        agent
      end
    end
  end
end
