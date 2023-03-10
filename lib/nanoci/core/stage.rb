# frozen_string_literal: true

require 'nanoci/core/job'
require 'nanoci/core/stage_state'
require 'nanoci/mixins/logger'

module Nanoci
  module Core
    # A stage represents a collection of jobs.
    # Each job is executed concurrently on a free agent
    # All jobs must complete successfully before build proceeds to the next stage
    # rubocop:disable Metrics:ClassLength
    class Stage
      include Nanoci::Mixins::Logger

      STAGE_HOOKS = %i[after_failure].freeze

      # @return [Symbol]
      attr_reader :tag

      # Gets project tag
      # @return [Symbol]
      attr_reader :project_tag

      # @return [Array<Symbol>]
      attr_reader :triggering_inputs

      # Inputs used for the previous successful stage execution
      # @return [Hash{Symbol => String}]
      attr_reader :prev_inputs

      # Pending inputs to be used when stage triggers next time
      # @return [Hash{Symbol => String}]
      attr_reader :pending_inputs

      # Current inputs
      # @return [Hash{Symbol => String}]
      attr_reader :inputs

      # @return [Hash{Symbol => String}]
      attr_reader :outputs

      # @return [Array<Nanoci::Job>]
      attr_reader :jobs


      attr_reader :state

      def idle? = state == State::IDLE

      def jobs_idle? = jobs.none?(&:active?)

      def success? = jobs.all?(&:success?)

      # Initializes new instance of [Stage]
      # @param tag [Symbol] Stage tag
      # @param inputs [Array<Symbol>] Array of triggering inputs
      # @param jobs [Array<Job>] Array of stage jobs
      # @return [Stage]
      def initialize(tag:, project_tag:, inputs:, jobs:, hooks:)
        raise ArgumentError, 'tag is not a Symbol' unless tag.is_a? Symbol

        @tag = tag.to_sym
        @project_tag = project_tag
        @triggering_inputs = inputs
        @jobs = jobs
        @hooks = hooks
        @inputs = {}
        @prev_inputs = {}
        @pending_inputs = {}
        @trigger_queue = []
        @outputs = {}
        @state = State::IDLE
      end

      def find_job(tag) = @jobs.select { |x| x.tag == tag }.first

      # Determines if there are changes in stage triggering inputs
      # @param next_inputs [Hash{Symbol => String}]
      def should_trigger?(next_inputs)
        triggering_inputs.empty? || triggering_inputs.any? do |ti|
          next_inputs.key?(ti) && next_inputs[ti] != inputs.fetch(ti, nil)
        end
      end

      def trigger(inputs)
        @pending_inputs.merge!(inputs)

        return unless should_trigger?(@pending_inputs)

        next_inputs = @pending_inputs
        @pending_inputs = {}
        if idle?
          run(next_inputs)
        else
          @trigger_queue.push(next_inputs)
        end
      end

      # Runs the jobs with the new inputs
      # @param next_inputs [Hash{Symbol => String}]
      # @return [Array] an array of jobs to schedule for execution
      def run(next_inputs)
        return unless should_trigger? next_inputs

        log.info "starting stage <#{tag}> with inputs #{next_inputs}"
        @prev_inputs = @inputs
        @inputs = @inputs.merge(next_inputs)
        self.state = Stage::State::RUNNING
        @jobs.each(&:schedule)
      end

      def job_complete(job_tag, outputs)
        job = find_job(job_tag)
        job.finalize(true, outputs)
        finalize if jobs_idle?
      end

      def finalize
        @outputs = @jobs.map(&:outputs).reduce(:merge).merge(@inputs) if success?
        log.info "stage <#{tag}> is completed with outputs #{outputs}"
        if @trigger_queue.empty?
          self.state = Stage::State::IDLE
        else
          next_inputs = @trigger_queue.unshift
          run(next_inputs)
        end
      end

      def validate
        validate_triggering_inputs
        validate_jobs
      end

      def memento
        {
          tag: tag,
          state: state,
          jobs: @jobs.to_h { |j| [j.tag, j.memento] },
          inputs: @inputs,
          outputs: @outputs,
          pending_outputs: @pending_outputs,
          pending_inputs: @pending_inputs,
          trigger_queue: @trigger_queue
        }
      end

      STAGE_HOOKS.each do |hook|
        class_eval <<-CODE, __FILE__, __LINE__ + 1
          def hook_#{hook} = @hooks.fetch(:#{hook}, nil)    # def hook_after_failure = @hooks.fetch(:after_failure, nil)
        CODE
      end

      # rubocop:disable Metrics:ABCSize
      def memento=(memento)
        raise ArgumentError, "stage tag #{tag} does not match memento tag #{memento[:tag]}" unless tag == memento[:tag]

        @state = memento.fetch(:state)
        @downstream_trigger_rule = memento.fetch(:downstream_trigger_rule, DownstreamTriggerRule.queue)
        @inputs = memento.fetch(:inputs, {})
        @outputs = memento.fetch(:outputs, {})
        @pending_outputs = memento.fetch(:pending_outputs, {})
        @pending_inputs = memento.fetch(:pending_inputs, {})
        @trigger_queue = memento.fetch(:trigger_queue, [])
        memento.fetch(:jobs, {}).each { |tag, job_memento| find_job(tag)&.memento = job_memento }
      end
      # rubocop:enable Metrics:ABCSize

      def to_s = "##{tag}"

      private

      def state=(next_state)
        raise "invalid state #{next_state}" unless State::VALUES.include? next_state

        transition = [@state, next_state]
        @state = next_state

        case transition
        in [State::IDLE, State::RUNNING] | [State::RUNNING, State::IDLE]
          log.info "stage <#{tag}> state changed from #{transition[0]} to #{transition[1]}"
        else
          raise ArgumentError, "invalid Stage transition #{transition}"
        end
      end

      def validate_triggering_inputs
        raise ArgumentError, 'inputs must be an Array' if triggering_inputs.nil? || !triggering_inputs.is_a?(Array)
      end

      def validate_jobs
        raise ArgumentError, 'jobs must be an Array' if jobs.nil? || !jobs.is_a?(Array)

        jobs.each(&:validate)
      end
    end
  end
end
