# frozen_string_literal: true

require 'nanoci'
require 'nanoci/agent_manager'
require 'nanoci/config'
require 'nanoci/config/ucs'
require 'nanoci/dsl/script_dsl'
require 'nanoci/events/workflow_config'
require 'nanoci/log'
require 'nanoci/messaging/subscriber'
require 'nanoci/messaging/subscription_factory'
require 'nanoci/messaging/topic_factory'
require 'nanoci/mixins/logger'
require 'nanoci/pipeline_engine'
require 'nanoci/plugin_host'
require 'nanoci/project'
require 'nanoci/remote/agent_manager_service_host'
require 'nanoci/state_manager'
require 'nanoci/utils/hash_utils'

module Nanoci
  class Application
    # nano-ci entry point
    class Service
      include Nanoci::Mixins::Logger

      def main(argv)
        log.info 'nano-ci starting...'

        Config::UCS.initialize(argv)
        setup_components
        project = load_project(Config::UCS.instance.project)

        log.info 'nano-ci is running'

        run(project)
      end

      private

      # @return [Nanoci::AgentManager]
      attr_reader :agent_manager

      # @return [Nanoci::StateManager]
      attr_reader :state_manager

      def setup_components
        ucs = Config::UCS.instance
        @plugin_host = load_plugins(File.expand_path(ucs.plugins_path))
        # @state_manager = StateManager.new(ucs.mongo_connection_string)
        @pipeline_engine = PipelineEngine.new(@plugin_host)
        @workflow_event_subscribers = setup_workflow_event_subscribers
      end

      # Sets up workflow event suscribers
      # @return [Array<Nanoci::Messaging::Subscriber>]
      def setup_workflow_event_subscribers
        topic_factory = Messaging::TopicFactory.new
        subscription_factory = Messaging::SubscriptionFactory.new
        Events::WorkflowConfig.setup_topics_and_subscriptions(topic_factory, subscription_factory)

        [
          Events::ExecuteJobSubscriber.new(topic_factory, subscription_factory)
        ]
      end

      # runs a nano-ci main service
      # @param project [Nanoci::Project]
      # @return [void]
      def run(project)
        @pipeline_engine.run_pipeline(project.pipeline)
        message_loop
      end

      def message_loop
        loop do
          had_messages = false
          @workflow_event_subscribers.each do |s|
            had_messages ||= s.pipe_messages
          rescue StandardError => e
            log.error "failed to run message loop for subscriber #{s.name} due to unhandled error"
            log.error e
          end

          sleep(0.1) unless had_messages
        end
      end

      def load_plugins(plugins_path)
        log.debug "loading plugins from #{plugins_path}..."
        # TODO: pass plugins_path to PluginHost
        PluginHost.new
      end

      # Reads project from the file
      # @param project_path [String]
      # @return [Nanoci::Project]
      def load_project(project_path)
        log.info "reading project definition from #{project_path}..."
        script_text = File.read(project_path)
        log.debug "input script text:\n#{script_text}"
        script_dsl = DSL::ScriptDSL.from_string(script_text)
        project_dsl = script_dsl.projects[0]
        log.info "read project #{project_dsl.tag}"
        Project.new(**project_dsl.build)
      end
    end
  end
end
