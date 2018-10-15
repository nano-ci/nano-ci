# frozen_string_literal: true

require 'yaml'

require 'nanoci'
require 'nanoci/agent_manager'
require 'nanoci/build_scheduler'
require 'nanoci/common_vars'
require 'nanoci/config'
require 'nanoci/definition/project_definition'
require 'nanoci/log'
require 'nanoci/mixins/logger'
require 'nanoci/options'
require 'nanoci/plugin_loader'
require 'nanoci/project'
require 'nanoci/state_manager'
require 'nanoci/utils/hash_utils'

class Nanoci
  class Application
    # nano-ci entry point
    class Service
      include Nanoci::Mixins::Logger

      def main(args) # rubocop:disable Metrics/AbcSize
        log.info 'nano-ci starting...'

        options = Options.parse(args)
        config = Config.new(YAML.load_file(options.config))
        Nanoci.config = config
        env = setup_env(config)
        agent_manager = run_agents(config, env)
        load_plugins(File.expand_path(config.plugins_path))
        state_manager = StateManager.new(config.mongo_connection_string)
        project = load_project(options.project, state_manager)

        log.info 'nano-ci is running'

        run(config, agent_manager, state_manager, project, env)
      end

      def run(config, agent_manager, state_manager, project, env)
        build_scheduler = run_build_scheduler(
          config.job_scheduler_interval,
          agent_manager,
          state_manager,
          env
        )

        run_triggers(project, build_scheduler, env)

        event = Concurrent::Event.new
        event.reset
        event.wait
      end

      def load_plugins(plugins_path)
        log.debug "loading plugins from #{plugins_path}..."
        PluginLoader.load(plugins_path)
      end

      def load_project(project_path, state_manager)
        log.info 'reading project definition...'
        project_definition_src = YAML.load_file(project_path).symbolize_keys
        project_definition = Definition::ProjectDefinition.new(project_definition_src)
        project = Project.new(project_definition)
        project_state = state_manager.get_state(
          StateManager::Types::PROJECT,
          project.tag
        )
        project.state = project_state unless project_state.nil?
        log.info "read project #{project.tag}"
        project
      end

      def run_agents(config, env)
        log.debug 'running agents...'
        AgentManager.new(config, env)
      end

      # runs triggers
      # @param project [Project]
      # @param build_scheduler [BuildScheduler]
      # @param env [Hash]
      def run_triggers(project, build_scheduler, env)
        project.repos.each do |_key, repo|
          repo.triggers.each do |trigger|
            trigger.run(build_scheduler, project, env)
          end
        end
      end

      def run_build_scheduler(interval, agent_manager, state_manager, env)
        build_scheduler = BuildScheduler.new(agent_manager, state_manager, env)
        build_scheduler.run(interval)
        build_scheduler
      end

      def setup_env(config)
        env = config.capabilities.clone
        env[CommonVars::REPO_CACHE] = config.repo_cache
        env[CommonVars::BUILD_DATA_DIR] = config.build_data_dir

        norm_env_vars = Hash[Bundler::ORIGINAL_ENV].transform_keys(&:to_sym)

        env.merge(norm_env_vars)
      end
    end
  end
end
