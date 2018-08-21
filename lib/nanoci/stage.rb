# frozen_string_literal: true

require 'nanoci/job'

class Nanoci
  # A stage represents a collection of jobs.
  # Each job is executed concurrently on a free agent
  # All jobs must complete successfully before build proceeds to the next stage
  class Stage
    attr_accessor :tag
    attr_accessor :jobs

    # Initializes new instance of [Stage]
    # @param definition [StageDefinition]
    # @param project [Project]
    # @return [Stage]
    def initialize(definition, project)
      @tag = definition.tag
      @jobs = read_jobs(definition.jobs, project)
    end

    private

    def read_jobs(job_definitions, project)
      job_definitions.map { |d| Job.new(d, project) }
    end
  end
end
