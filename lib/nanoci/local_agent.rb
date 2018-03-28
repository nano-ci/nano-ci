# frozen_string_literal: true

require 'logging'

require 'nanoci/agent'
require 'nanoci/build'

class Nanoci
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
    end
  end
end
