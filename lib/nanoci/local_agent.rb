# frozen_string_literal: true

require 'concurrent'
require 'logging'

require 'nanoci/agent'
require 'nanoci/agent_status'
require 'nanoci/build'
require 'nanoci/config/ucs'

module Nanoci
  ##
  # Local agent is the agent that executes jobs in the main nano-ci process
  class LocalAgent < Agent
    include Logging.globally

    def initialize
      @tag = Config::UCS.instance.agent_tag
      @capabilities = Config::UCS.instance.agent_capabilities
      @workdir = Config::UCS.instance.workdir
      super(tag, capabilities)
    end

    # Runs a job on the agent
    # @param build [Nanoci::Build]
    # @param job [Nanoci::BuildJob]
    # @return [Concurrent::Promises::Future]
    def run_job(build, job)
      job_done_event = super(build, job)

      Concurrent::Promises
        .future(build, job, &method(:run_job_impl))
        .then(&method(:finalize_job_execution))

      job_done_event
    end

    private

    def execute_tasks(tasks, job_tag, build)
      tasks.each { |task| execute_task(build, job_tag, task) }
    end

    def execute_task(build, job_tag, task)
      logger.debug "executing task #{task.type} of #{job_tag}"

      build_work_dir = File.join(@workdir, build.tag)

      task.execute(build, build_work_dir)
      logger.debug "task #{task.type} of #{job_tag} is done"
    rescue StandardError => e
      logger.error "failed to execute task #{task} from job #{job_tag} of build #{build.tag}"
      logger.error(e)
      raise e
    end

    def run_job_impl(build, job)
      begin
        self.status = AgentStatus::BUSY
        job.state = Build::State::RUNNING
        execute_tasks(job.definition.tasks, job.tag, build)
        job.state = Build::State::COMPLETED
      rescue StandardError => e
        logger.error "failed to execute job #{job.tag} of build #{build.tag}"
        logger.error e
        job.state = Build::State::FAILED
      end

      finalize_job_execution
    end

    def finalize_job_execution
      @current_job = nil
      @build = nil
      self.status = AgentStatus::IDLE
    end
  end
end
