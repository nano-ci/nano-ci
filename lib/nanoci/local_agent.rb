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

      job.state = Build::State::RUNNING

      job.definition.tasks.each do |task|
        begin
          execute_task(build, task)
        rescue StandardError => e
          @log.error(e)
          job.state = Build::State::FAILED
        end
      end
      job.state = Build::State::COMPLETED
    end
  end
end
