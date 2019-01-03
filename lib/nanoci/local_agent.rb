# frozen_string_literal: true

require 'logging'

require 'nanoci/agent'
require 'nanoci/build'

module Nanoci
  ##
  # Local agent is the agent that executes jobs in the main nano-ci process
  class LocalAgent < Agent
    def initialize(*args)
      super

      @log = Logging.logger[self]
    end

    def run_job(build, job)
      super(build, job)

      begin
        job.state = Build::State::RUNNING
        execute_tasks(job.definition.tasks, job.tag, build)
        job.state = Build::State::COMPLETED
      rescue StandardError => e
        @log.error "failed to execute job #{job.tag} of build #{build.tag}"
        @log.error e
        job.state = Build::State::FAILED
      end
      self.current_job = nil
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
