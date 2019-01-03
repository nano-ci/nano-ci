# frozen_string_literal: true

require 'yaml'

require 'nanoci'
require 'nanoci/agent_manager'
require 'nanoci/build_scheduler'
require 'nanoci/config'
require 'nanoci/config/ucs'
require 'nanoci/definition/project_definition'
require 'nanoci/log'
require 'nanoci/mixins/logger'
require 'nanoci/options'
require 'nanoci/plugin_loader'
require 'nanoci/project'
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
        setup_components(argv)
        project = load_project(ucs.project)

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
        @state_manager = StateManager.new(ucs.mongo_connection_string)
      end

      # runs a nano-ci main service
      # @param ucs [Nanoci::Config::UCS]
      # @return [void]
      def run(project)
        build_scheduler = run_build_scheduler(
          Config::UCS.instance.job_scheduler_interval,
          agent_manager,
          state_manager
        )

        run_triggers(project, build_scheduler)

        event = Concurrent::Event.new
        event.reset
        event.wait
      end

      def load_plugins(plugins_path)
        log.debug "loading plugins from #{plugins_path}..."
        PluginLoader.load(plugins_path)
      end

      def load_project(project_path, state_manager)
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
      # @param ucs [Nanoci::Config::UCS]
      def run_triggers(project, build_scheduler)
        project.repos.each do |_key, repo|
          repo.triggers.each do |trigger|
            trigger.run(build_scheduler, project)
          end
        end
      end

      # runs a build scheduler
      # @param interval [Number]
      # @param agent_manager [Nanoci::AgentManager]
      # @param state_manager [Nanoci::StateManager]
      # @param ucs [Nanoci::Config::UCS]
      def run_build_scheduler(interval, agent_manager, state_manager)
        build_scheduler = BuildScheduler.new(agent_manager, state_manager)
        build_scheduler.run(interval)
        build_scheduler
      end
    end
  end
end
