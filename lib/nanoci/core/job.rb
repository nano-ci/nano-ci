# frozen_string_literal: true

require 'nanoci/core/job_state'

module Nanoci
  module Core
    # A job is a collection of tasks to run actions and produce artifacts
    class Job
      # @return [Symbol]
      attr_reader :tag

      # @return [String] Relative path to directory where the job should execute
      attr_reader :work_dir

      # @return [Proc]
      attr_reader :body

      # @return [Hash|Proc]
      attr_reader :env

      attr_reader :state

      # Gets status of the most recent job run
      # @return [Boolean] true if job complete successfully; false otherwise
      attr_reader :success

      # Gets outputs of the most recent success job run
      # @return [Hash{Symbol => String}]
      attr_reader :outputs

      def state=(next_state)
        raise ArgumentError, "invalid state #{next_state}" unless State::VALUES.include? next_state

        @state = next_state
      end

      # Initializes new instance of [Job]
      # @param tag [Symbol] The job tag
      # @param body [Block] The job body block
      # @param work_dir [String] The job work dir relative to build path
      # @param env [Hash|Proc] Job environment variables. Can be either a hash or proc that returns a hash
      def initialize(tag:, body:, work_dir: '.', env: nil)
        @tag = tag&.to_sym
        @work_dir = work_dir
        @body = body
        @env = env
        @state = State::IDLE
        @outputs = {}
      end

      def validate
        raise ArgumentError, 'tag is nil' if tag.nil?

        raise ArgumentError, 'body is nil' if body.nil?
        raise ArgumentError, 'body is not a Proc' unless body.is_a? Proc
      end

      def finalize(success, outputs)
        raise ArgumentError, 'success is not a Boolean' unless [true, false].include? success
        raise ArgumentError, 'outputs is not a Hash' unless outputs.is_a? Hash

        @success = success
        @outputs = outputs if success

        self.state = State::IDLE
      end
    end
  end
end
