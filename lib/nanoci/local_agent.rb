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
    def initialize
      tag = Config::UCS.instance.agent_tag
      capabilities = Config::UCS.instance.agent_capabilities
      super(tag, capabilities)

      @log = Logging.logger[self]
    end

    def run_job(build, job)
      super(build, job)

      future = Concurrent::Promises.future do
        self.status = AgentStatus::BUSY
        job.state = Build::State::RUNNING
        execute_tasks(job.definition.tasks, job.tag, build)
        job.state = Build::State::COMPLETED
      end

      future = future.then begin
        @current_job = nil
        @build = nil
        self.status = AgentStatus::IDLE
      end

      future = future.rescue do
        @log.error "failed to execute job #{job.tag} of build #{build.tag}"
        @log.error e
        job.state = Build::State::FAILED
      end

      future
    end

    def execute_tasks(tasks, job_tag, build)
      tasks.each { |task| execute_task(build, job_tag, task) }
    end

    def execute_task(build, job_tag, task)
      @log.debug "executing task #{task.type} of #{job_tag}"

      build_work_dir = File.join(@workdir, build.tag)

      task.execute(build, build_work_dir)
      @log.debug "task #{task.type} of #{job_tag} is done"
    rescue StandardError => e
      @log.error "failed to execute task #{task} from job #{job_tag} of build #{build.tag}"
      @log.error(e)
      raise e
    end
  end
end
