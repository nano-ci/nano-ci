# frozen_string_literal: true

require 'nanoci/config/ucs'
require 'nanoci/remote/agent_manager_services_rb'
require 'nanoci/remote/report_agent_status_message_pb.rb'

module Nanoci
  module Remote
    # Agent manager service client
    class AgentManagerServiceClient
      def initialize
        @service_uri = Config::UCS.instance.agent_manager_service_uri
        @client = AgentManager::Service::Stub.new(@service_uri)
      end

      # Reports agent status to nano-ci service
      # @param tag [Symbol] agent tag
      # @param status [Symbol] agent status
      # @param capabilities [Array<Symbol>] agent capabilities
      def report_agent_status(tag, status, capabilities)
        request = ReportAgentStatusRequest.new(
          tag: tag.to_s,
          status: status.to_s,
          capabilities: capabilities.map(&:to_s)
        )
        @client.report_agent_status(request)
      end
    end
  end
end
