# frozen_string_literal: true

require 'nanoci/agent_engine'
require 'nanoci/config/ucs'
require 'nanoci/event_engine'
require 'nanoci/log'
require 'nanoci/mixins/logger'
require 'nanoci/plugin_loader'

module Nanoci
  class Application
    # Agent service entry point
    class Agent
      include Nanoci::Mixins::Logger

      def main(argv)
        log.info('nano-ci agent is starting...')

        ucs = Config::UCS.initialize(argv)
        load_plugins(File.expand_path(ucs.plugins_path))

        event_engine = EventEngine.new

        engine = AgentEngine.new(event_engine)
        engine.run.wait!
      end

      def load_plugins(plugins_path)
        log.debug "loading plugins from #{plugins_path}..."
        PluginLoader.load(plugins_path)
      end
    end
  end
end
