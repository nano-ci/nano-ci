# frozen_string_literal: true

require 'nanoci/build_job'

module Nanoci
  ##
  # BuildStage is the class to track Build Stage execution
  class BuildStage
    attr_accessor :definition
    attr_accessor :jobs

    def initialize(build, definition)
      @definition = definition
      @jobs = @definition.jobs.map { |j| BuildJob.new(build, j) }
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
