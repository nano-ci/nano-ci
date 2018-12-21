# frozen_string_literal: true

require 'nanoci/remote_agent'
require 'nanoci/remote/agent_manager_services_pb'

class Nanoci
  class Remote
    # Implementation of RPC service AgentManager
    class AgentManagerServiceImpl < AgentManager::Service
      attr_reader :agent_manager

      def initialize(agent_manager)
        @agent_manager = agent_manager
      end

      # Report remote agent status and capabilities
      # @param report_agent_status_request [ReportAgentStatusRequest]
      # @param _call [Object]
      def report_agent_status(report_agent_status_request, _call)
        tag = report_agent_status_request.tag
        status = report_agent_status_request.status
        capabilities = report_agent_status_request.capabilities
        agent = agent_manager.get_agent(tag)
        if agent.nil?
          agent = RemoteAgent.new(tag, capabilities)
          agent_manager.add_agent_to_pool(agent)
        end
        agent.status = status
        agent.capabilities = capabilities
      end
    end
  end
end
