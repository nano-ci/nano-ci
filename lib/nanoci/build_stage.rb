require 'nanoci/build_job'

class Nanoci
  class BuildStage
    attr_accessor :definition
    attr_accessor :jobs

    def initialize(definition)
      @definition = definition
      @jobs = @definition.jobs.map { |j| BuildJob.new(j) }
    end

    def state
      jobs.map(&:state).min
    end
  end
end
