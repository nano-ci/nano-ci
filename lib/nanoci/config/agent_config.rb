# frozen_string_literal: true

module Nanoci
  # Module to group config classes
  module Config
    # nano-ci agent service config
    module AgentConfig
      def tag
        get(AgentConfig::AGENT_TAG)
      end

      # @return [Hash<Symbol, String>]
      def capabilities
        caps = (get(AgentConfig::CAPABILITIES) || []).map do |x|
          case x
          when String then [x, nil]
          when Hash then x.entries[0]
          end
        end
        caps.map { |x| [x[0].to_sym, x[1]] }.to_h
      end

      def workdir
        get(AgentConfig::WORKDIR)
      end

      # agent.tag config name
      AGENT_TAG = :'agent.tag'

      CAPABILITIES = :'agent.capabilities'

      # workdir config name
      WORKDIR = :workdir
    end
  end
end
