# frozen_string_literal: true

require 'nanoci/agent_options'
require 'nanoci/mixins/logger'

module Nanoci
  class Application
    # Agent service entry point
    class Agent
      include Nanoci::Mixins::Logger

      def main(cli_args)
        log.info('nano-ci agent is starting...')

        args = AgentOptions.parse(cli_args)

      end

      private

      def setup_env(config)
        norm_env_vars = Hash[Bundler::ORIGINAL_ENV].transform_keys(&:to_sym)

        env.merge(norm_env_vars)
      end
    end
  end
end
