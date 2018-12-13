# frozen_string_literal: true

require 'nanoci_remote/agent_manager_services_pb'

class Nanoci
  class Remote
    # Implementation of RPC service AgentManager
    class AgentManagerServiceImpl < AgentManager::Service
      attr_reader :agent_manager

      def initialize(agent_manager)
        @agent_manager = agent_manager
      end


      def report_agent_status(report_agent_status_request, _call)
        agent = agent_manager.get_agent(report_agent_status_request.tag)
        if agent.nil?
          # TODO: Create new agent
        end
        agent.status =
      end
    end
  end
end
