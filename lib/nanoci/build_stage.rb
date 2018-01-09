require 'nanoci/build_job'

class Nanoci
  class BuildStage
    attr_accessor :stage
    attr_accessor :jobs

    def initialize(stage)
      @stage = stage
      @jobs = @stage.jobs.map { |j| BuildJob.new(j) }
    end

    def state
      jobs.map(&:state).min
    end
  end
end
