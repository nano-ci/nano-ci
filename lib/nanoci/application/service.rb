# frozen_string_literal: true

require 'yaml'

require 'nanoci'
require 'nanoci/agent_manager'
require 'nanoci/build_scheduler'
require 'nanoci/config'
require 'nanoci/config/ucs'
require 'nanoci/definition/project_definition'
require 'nanoci/event_engine'
require 'nanoci/log'
require 'nanoci/mixins/logger'
require 'nanoci/plugin_loader'
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
        load_plugins(File.expand_path(ucs.plugins_path))
        log.debug 'running agents...'
        @agent_manager = AgentManager.new
        @agent_manager_service = Remote::AgentManagerServiceHost.new(@agent_manager)
        @state_manager = StateManager.new(ucs.mongo_connection_string)
        @event_engine = EventEngine.new
        @build_scheduler = BuildScheduler.new(agent_manager, state_manager, @event_engine)
      end

      # runs a nano-ci main service
      # @return [void]
      def run(project)
        @agent_manager_service.run
        run_triggers(project, @build_scheduler)
        @build_scheduler
          .run(Config::UCS.instance.job_scheduler_interval)
          .wait!
      end

      def load_plugins(plugins_path)
        log.debug "loading plugins from #{plugins_path}..."
        PluginLoader.load(plugins_path)
      end

      def load_project(project_path)
        log.info "reading project definition from #{project_path}..."
        project_definition_src = YAML.load_file(project_path).symbolize_keys
        project_definition = Definition::ProjectDefinition.new(project_definition_src)
        project = Project.new(project_definition)
        project_state = state_manager.get_state(StateManager::Types::PROJECT, project.tag)
        project.state = project_state unless project_state.nil?
        log.info "read project #{project.tag}"
        project
      end

      # runs triggers
      # @param project [Nanoci::Project]
      # @param build_scheduler [Nanoci::BuildScheduler]
      def run_triggers(project, build_scheduler)
        project.repos.each do |_key, repo|
          repo.triggers.each do |trigger|
            trigger.run(build_scheduler, project)
          end
        end
      end
    end
  end
end
