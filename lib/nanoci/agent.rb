# frozen_string_literal: true

require 'logging'

require 'nanoci/common_vars'

module Nanoci
  # Agent is a instance of nano-ci service that executes commands from
  # a main nano-ci service to run build jobs
  class Agent
    attr_accessor :name
    attr_accessor :current_job
    attr_accessor :workdir

    def initialize(config, capabilities, env)
      @log = Logging.logger[self]
      @name = config.name

      raise 'capabilities should be a Hash' unless capabilities.is_a? Hash
      @capabilities = config.capabilities.merge(capabilities)
      @workdir = config.workdir
      FileUtils.mkdir_p(@workdir) unless Dir.exist? @workdir
      @env = env
      @current_job = nil
    end

    def run_job(_build, job)
      @log.info "running job #{job.tag} on #{name}"
      self.current_job = job
    end

    def capabilities
      @capabilities
    end

    def capability(name)
      @capabilities.key?(name) ? @capabilities[name] || true : nil
    end

    def capability?(required_capability)
      @capabilities.key?(required_capability)
    end

    def capabilities?(required_capabilities)
      raise 'required_capabilities should be a Set' \
        unless required_capabilities.is_a? Set
      Set.new(@capabilities.keys.to_set).superset? required_capabilities
    end

    def execute_tasks(tasks, job_tag, build)
      tasks.each { |task| execute_task(build, job_tag, task) }
    end

    def execute_task(build, job_tag, task)
      @log.debug "executing task #{task.type} of #{job_tag}"
      env = @env.merge(@capabilities)

      build_work_dir = File.join(@workdir, build.tag)
      env[CommonVars::WORKDIR] = build_work_dir

      task.execute(build, env)
      @log.debug "task #{task.type} of #{job_tag} is done"
    rescue StandardError => e
      @log.error "failed to execute task #{task} from job #{job_tag} of build #{build.tag}"
      @log.error(e)
      raise e
    end
  end
end
