require 'eventmachine'
require 'logging'
require 'yaml'

require 'nanoci/log'

require 'nanoci/agent_manager'
require 'nanoci/build_scheduler'
require 'nanoci/config'
require 'nanoci/options'
require 'nanoci/plugin_loader'
require 'nanoci/project_loader'
require 'nanoci/state_manager'

##
# Main entry point
class Nanoci
  class << self
    attr_accessor :agent_manager
    attr_accessor :build_scheduler
    attr_accessor :state_manager
  end

  def self.main(args)
    @log = Logging.logger[self]
    @log.info 'nano-ci starting...'

    options = Options.parse(args)
    config = Config.new(YAML.load_file(options.config))

    env = setup_env(config)

    @log.debug 'running agents...'
    run_agents(config, env)

    @log.debug 'loading plugins...'
    PluginLoader.load(File.expand_path(config.plugins_path))

    self.state_manager = StateManager.new(config.mongo_connection_string)

    @log.info 'reading project definition...'
    project = ProjectLoader.new.load(options.project)
    project_state = state_manager.get_state(StateManager::Types::PROJECT, project.tag)
    project.state = project_state unless project_state.nil?
    @log.info "read project #{project.tag}"

    @log.info 'nano-ci is running'


    EventMachine.run do
      run_build_scheduler(config.job_scheduler_interval, state_manager, env)

      run_triggers(project, build_scheduler, env)
    end
  end

  def self.run_agents(config, env)
    self.agent_manager = AgentManager.new(config, env)
  end

  def self.run_triggers(project, build_scheduler, env)
    project.repos.each do |key, repo|
      repo.triggers.each { |trigger| trigger.run(build_scheduler, env) }
    end
  end

  def self.run_build_scheduler(interval, state_manager, env)
    self.build_scheduler = BuildScheduler.new(agent_manager, state_manager, env)
    build_scheduler.run(interval)
  end

  def self.setup_env(config)
    env = config.capabilities.clone
    env['repo_cache'] = config.repo_cache
    env['build_data_dir'] = config.build_data_dir
    env
  end
end
