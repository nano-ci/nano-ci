require 'nanoci/agent'
require 'nanoci/build'

class Nanoci
  class LocalAgent < Agent
    def run_job(job)
      super(job)

      job.state = Build.State::RUNNING
    end
  end
end
