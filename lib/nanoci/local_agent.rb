require 'logging'

require 'nanoci/agent'
require 'nanoci/build'

class Nanoci
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

    def execute_tasks(tasks, job_tag, build)
      tasks.each do |task|
        begin
          execute_task(build, task)
        rescue StandardError => e
          @log.error "failed to execute task #{task} from job #{job_tag} of build #{build.tag}"
          @log.error(e)
          raise e
        end
      end
    end
  end
end
