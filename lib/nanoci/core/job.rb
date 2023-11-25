# frozen_string_literal: true

require_relative 'job_state'

module Nanoci
  module Core
    # A job is a collection of tasks to run actions and produce artifacts
    class Job
      # @return [Symbol]
      attr_reader :tag

      def full_tag = "#{project.tag}:#{stage.tag}:#{tag}".to_sym

      # @return [Nanoci::Core::Stage]
      attr_accessor :stage

      # @return [Nanoci::Core::Project]
      attr_accessor :project

      # @return [String] Relative path to directory where the job should execute
      attr_reader :work_dir

      # @return [Proc]
      attr_reader :body

      # @return [Hash|Proc]
      attr_reader :env

      # @return [Nanoci::Core::Job::State]
      attr_reader :state

      # @return [String]
      attr_reader :docker_image

      # Gets outputs of the most recent success job run
      # @return [Hash{Symbol => String}]
      attr_reader :outputs

      def active? = State::ACTIVE.include?(state)
      def running? = state == State::RUNNING
      def success? = state == State::SUCCESSFUL

      def state=(next_state)
        raise ArgumentError, "invalid state #{next_state}" unless State::VALUES.include? next_state

        @state = next_state
      end

      # Initializes new instance of [Job]
      # @param tag [Symbol] The job tag
      # @param body [Block] The job body block
      # @param work_dir [String] The job work dir relative to build path
      # @param env [Hash|Proc] Job environment variables. Can be either a hash or proc that returns a hash
      def initialize(tag:, body:, work_dir: '.', env: nil, docker_image: nil)
        raise ArgumentError, 'tag is nil' if tag.nil?

        @tag = tag.to_sym
        @work_dir = work_dir
        @body = body
        @env = env
        @docker_image = docker_image
        @state = State::PENDING
        @outputs = {}
        @stage = nil
        @project = nil
      end

      def validate
        raise ArgumentError, 'tag is nil' if tag.nil?

        raise ArgumentError, 'body is nil' if body.nil?
        raise ArgumentError, 'body is not a Proc' unless body.is_a? Proc
      end

      def schedule
        self.state = Job::State::SCHEDULED
      end

      def finalize(success, outputs)
        raise ArgumentError, 'success is not a Boolean' unless [true, false].include? success
        raise ArgumentError, 'outputs is not a Hash' unless outputs.is_a? Hash

        self.state = success ? State::SUCCESSFUL : State::FAILED

        @outputs = outputs if state == State::SUCCESSFUL
      end

      def canceled
        self.state = State::CANCELED
      end

      def memento
        {
          tag: tag,
          state: state,
          outputs: outputs
        }
      end

      def memento=(memento)
        raise ArgumentError, "stage tag #{tag} does not match memento tag #{memento[:tag]}" unless tag == memento[:tag]

        @state = memento.fetch(:state)
        @outputs = memento.fetch(:outputs, {})
      end

      def to_s = "<#{project.tag}.#{stage.tag}.#{tag}>"
    end
  end
end
