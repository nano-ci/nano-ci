# frozen_string_literal: true

require 'nanoci/build_job'

module Nanoci
  ##
  # BuildStage is the class to track Build Stage execution
  class BuildStage
    attr_accessor :definition
    attr_accessor :jobs

    # Gets a future resolved when all jobs in the stage are completed
    # @return [Concurrent::Promises::Future]
    attr_reader :completed_future

    def initialize(build, definition)
      @definition = definition
      @jobs = @definition.jobs.map { |j| BuildJob.new(build, j) }
      @completed_future = Concurrent::Promises
                          .zip_futures_over(@jobs.map(&:completed_future))
    end

    def state
      jobs.map(&:state).min
    end

    def tag
      @definition.tag
    end

    def memento
      {
        tag: tag,
        jobs: Hash[jobs.map { |j| [j.tag, j.memento] }],
        stage: Build::State.key(state)
      }
    end
  end
end
