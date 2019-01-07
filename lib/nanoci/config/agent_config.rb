# frozen_string_literal: true

module Nanoci
  # Module to group config classes
  module Config
    # nano-ci agent service config
    module AgentConfig
      def agent_tag
        get(AgentConfig::AGENT_TAG)
      end

      def agent_manager_service_uri
        get(AgentConfig::AGENT_MANAGER_SERVICE_URI)
      end

      def build_data_dir
        get(AgentConfig::BUILD_DATA_DIR)
      end

      # @return [Hash<Symbol, String>]
      def agent_capabilities
        caps = (get(AgentConfig::CAPABILITIES) || []).map do |x|
          case x
          when String then [x, nil]
          when Hash then x.entries[0]
          end
        end
        caps.map { |x| [x[0].to_sym, x[1]] }.to_h
      end

      def report_status_interval
        get(AgentConfig::REPORT_STATUS_INTERVAL, 150)
      end

      def workdir
        get(AgentConfig::WORKDIR)
      end

      # build-data-dir config name
      BUILD_DATA_DIR = :'build-data-dir'

      # agent.tag config name
      AGENT_TAG = :'agent.tag'

      # agent.capabilities config name
      CAPABILITIES = :'agent.capabilities'

      # agent.manager_service_uri config name
      AGENT_MANAGER_SERVICE_URI = :'agent.manager_service_uri'

      # agent.report-status-interval config name
      REPORT_STATUS_INTERVAL = :'agent.report-status-interval'

      # workdir config name
      WORKDIR = :workdir
    end
  end
end
