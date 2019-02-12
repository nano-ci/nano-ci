# frozen_string_literal: true

require 'nanoci/job'

module Nanoci
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
    def initialize(definition)
      @tag = definition.tag
      @jobs = read_jobs(definition.jobs)
    end

    private

    def read_jobs(job_definitions)
      job_definitions.map { |d| Job.new(d) }
    end
  end
end
