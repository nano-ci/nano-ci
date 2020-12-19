# frozen_string_literal: true

require 'nanoci/job'

module Nanoci
  # A stage represents a collection of jobs.
  # Each job is executed concurrently on a free agent
  # All jobs must complete successfully before build proceeds to the next stage
  class Stage
    # @return [Symbol]
    attr_accessor :tag

    # @return [Array<Nanoci::Job>]
    attr_accessor :jobs

    # Initializes new instance of [Stage]
    # @param src [Hash]
    # @param project [Project]
    # @return [Stage]
    def initialize(src)
      @tag = src[:tag]
      @jobs = read_jobs(src[:jobs])
    end

    private

    def read_jobs(src)
      src.collect { |d| Job.new(d) }
    end
  end
end
