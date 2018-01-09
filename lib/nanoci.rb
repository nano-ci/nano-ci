require 'eventmachine'
require 'yaml'

require 'nanoci/agent_manager'
require 'nanoci/config'
require 'nanoci/options'
require 'nanoci/plugin_loader'
require 'nanoci/project_loader'

##
# Main entry point
class Nanoci
  class << self
    attr_accessor :agent_manager
    attr_accessor :job_scheduler
  end

  def self.main(args)
    options = Options.parse(args)
    config = Config.new(YAML.load_file(options.config))

    run_agents(config)

    PluginLoader.load(File.expand_path(config.plugins_path))

    project = ProjectLoader.load(options.project) unless options.project.nil?

    EventMachine.run do
      run_triggers(project)
      run_job_scheduler(config.job_scheduler_interval)
    end
  end

  def self.run_agents(config)
    self.agent_manager = AgentManager.new(config.local_agents)
  end

  def self.run_triggers(project)
    project.repos.each do |repo|
      repo.triggers.each { |trigger| trigger.run(repo, project) }
    end
  end

  def self.run_job_scheduler(interval)
    self.job_scheduler = JobScheduler.new(self.agents_manager)
    job.scheduler.run(interval)
  end

  def self.run_build(build)
    self.job_scheduler.run_build(build)
    puts "Starting build #{build.tag} at #{build.start_time}"
  end
end
