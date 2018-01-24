require 'nanoci/agent'
require 'nanoci/build'

class Nanoci
  class LocalAgent < Agent
    def run_job(job)
      super(job)

      job.state = Build::State::RUNNING

      job.definition.tasks.each do |t|
        begin
          execute_task(task)
        rescue
          job.state = Build::Stage::FAILED
        end
      end
    end

    def execute_task(task)
      # task.execute(agent)
    end
  end
end
