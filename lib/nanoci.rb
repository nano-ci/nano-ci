require 'eventmachine'
require 'logging'
require 'yaml'

require 'nanoci/agent_manager'
require 'nanoci/build_scheduler'
require 'nanoci/config'
require 'nanoci/options'
require 'nanoci/plugin_loader'
require 'nanoci/project_loader'

##
# Main entry point
class Nanoci
  class << self
    attr_accessor :agent_manager
    attr_accessor :build_scheduler
  end

  def self.main(args)
    options = Options.parse(args)
    config = Config.new(YAML.load_file(options.config))

    run_agents(config)

    PluginLoader.load(File.expand_path(config.plugins_path))

    project = ProjectLoader.new.load(options.project)
    EventMachine.run do
      run_build_scheduler(config.job_scheduler_interval)

      run_triggers(project, build_scheduler)
    end
  end

  def self.run_agents(config)
    self.agent_manager = AgentManager.new(config.local_agents)
  end

  def self.run_triggers(project, build_scheduler)
    project.repos.each do |key, repo|
      repo.triggers.each { |trigger| trigger.run(build_scheduler) }
    end
  end

  def self.run_build_scheduler(interval)
    self.build_scheduler = BuildScheduler.new(agent_manager)
    build_scheduler.run(interval)
  end

  def self.run_build(build)
    job_scheduler.run_build(build)
    puts "Starting build #{build.tag} at #{build.start_time}"
  end
end
