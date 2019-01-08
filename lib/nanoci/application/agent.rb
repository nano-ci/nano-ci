# frozen_string_literal: true

require 'nanoci/agent_engine'
require 'nanoci/config/ucs'
require 'nanoci/log'
require 'nanoci/mixins/logger'

module Nanoci
  class Application
    # Agent service entry point
    class Agent
      include Nanoci::Mixins::Logger

      def main(argv)
        log.info('nano-ci agent is starting...')

        Config::UCS.initialize(argv)

        engine = AgentEngine.new
        engine.run
      end
    end
  end
end
