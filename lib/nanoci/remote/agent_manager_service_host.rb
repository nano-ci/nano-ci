# frozen_string_literal: true

$LOAD_PATH.unshift __dir__

require 'concurrent'
require 'grpc'

require 'nanoci/config/ucs'
require 'nanoci/remote/agent_manager_service_impl'

# Enable GRPC logs
module GRPC
  extend Logging.globally
end

module Nanoci
  module Remote
    # Host class for agent manager service
    class AgentManagerServiceHost
      include Logging.globally

      # Initializes new instance of [AgentManagerServiceHost]
      # @param agent_manager [Nanoci::AgentManager]
      def initialize(agent_manager)
        # @type [Nanoci::AgentManager]
        @agent_manager = agent_manager

        # @type [String]
        @address = Config::UCS.instance.agent_service_host_address
      end

      def run
        @service = GRPC::RpcServer.new
        @service.add_http2_port(@address, :this_port_is_insecure)
        logger.info("hosting agent manager service on #{@address}")
        @service.handle(AgentManagerServiceImpl.new(@agent_manager))
        @service_run_future = Concurrent::Promises.future { @service.run }
        logger.info('agent manager service is running')
      end

      def stop
        @service.stop
        @service_run_future.wait!
      end
    end
  end
end
