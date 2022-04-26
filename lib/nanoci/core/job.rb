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

      attr_reader :state

      attr_accessor :success

      def state=(next_state)
        raise ArgumentError, "invalid state #{next_state}" unless State::VALUES.include? next_state

        @state = next_state
      end

      # Initializes new instance of [Job]
      # @param tag [Symbol] The job tag
      # @param body [Block] The job body block
      # @param work_dir [String] The job work dir relative to build path.
      def initialize(tag:, body:, work_dir: '.')
        @tag = tag&.to_sym
        @work_dir = work_dir
        @body = body
        @state = State::IDLE
      end

      def validate
        raise ArgumentError, 'tag is nil' if tag.nil?

        raise ArgumentError, 'body is nil' if body.nil?
        raise ArgumentError, 'body is not a Proc' unless body.is_a? Proc
      end
    end
  end
end
