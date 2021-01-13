# frozen_string_literal: true

require 'nanoci/job_state'

module Nanoci
  # A job is a collection of tasks to run actions and produce artifacts
  class Job
    # @return [Symbol]
    attr_reader :tag

    # @return [String] Relative path to directory where the job should execute
    attr_reader :work_dir

    # @return [Proc]
    attr_reader :body

    attr_reader :state

    def state=(next_state)
      raise "invalid state #{next_state}" unless State::VALUES.include? next_state

      @state = next_state
    end

    # Initializes new instance of [Job]
    # @param src [Hash]
    def initialize(src)
      @tag = src[:tag]
      @work_dir = src.fetch(:work_dir, '.')
      @body = src[:block]
      @state = State::IDLE
    end
  end
end
