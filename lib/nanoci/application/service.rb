# frozen_string_literal: true

require 'eventmachine'

require 'yaml'

require 'nanoci/log'

require 'nanoci/agent_manager'
require 'nanoci/build_scheduler'
require 'nanoci/config'
require 'nanoci/mixins/logger'
require 'nanoci/options'
require 'nanoci/plugin_loader'
require 'nanoci/project_loader'
require 'nanoci/state_manager'

class Nanoci
  class Application
    ##
    # nano-ci entry point
    class Service
      include Nanoci::Mixins::Logger

      def main(args) # rubocop:disable Metrics/AbcSize
        log.info 'nano-ci starting...'

        options = Options.parse(args)
        config = Config.new(YAML.load_file(options.config))
        env = setup_env(config)
        agent_manager = run_agents(config, env)
        load_plugins(File.expand_path(config.plugins_path))
        state_manager = StateManager.new(config.mongo_connection_string)
        project = load_project(options.project, state_manager)

        log.info 'nano-ci is running'

        run(config, agent_manager, state_manager, project, env)
      end

      def run(config, agent_manager, state_manager, project, env)
        EventMachine.run do
          build_scheduler = run_build_scheduler(
            config.job_scheduler_interval,
            agent_manager,
            state_manager,
            env
          )
          run_triggers(project, build_scheduler, env)
        end
      end

      def load_plugins(plugins_path)
        log.debug "loading plugins from #{plugins_path}..."
        PluginLoader.load(plugins_path)
      end

      def load_project(project_path, state_manager)
        log.info 'reading project definition...'
        project = ProjectLoader.new.load(project_path)
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

      def run_triggers(project, build_scheduler, env)
        project.repos.each do |_key, repo|
          repo.triggers.each { |trigger| trigger.run(build_scheduler, env) }
        end
      end

      def run_build_scheduler(interval, agent_manager, state_manager, env)
        build_scheduler = BuildScheduler.new(agent_manager, state_manager, env)
        build_scheduler.run(interval)
        build_scheduler
      end

      def setup_env(config)
        env = config.capabilities.clone
        env['repo_cache'] = config.repo_cache
        env['build_data_dir'] = config.build_data_dir
        env
      end
    end
  end
end
