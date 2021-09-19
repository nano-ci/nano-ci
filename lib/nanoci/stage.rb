# frozen_string_literal: true

require 'logging'

require 'nanoci/job'
require 'nanoci/stage_state'

module Nanoci
  # A stage represents a collection of jobs.
  # Each job is executed concurrently on a free agent
  # All jobs must complete successfully before build proceeds to the next stage
  class Stage
    # @return [Symbol]
    attr_reader :tag

    # Gets stage's pipeline.
    # @return [Nanoci::Pipeline]
    attr_reader :pipeline

    # @return [Array<Symbol>]
    attr_reader :triggering_inputs

    # Inputs used for the last successful stage execution
    # @return [Hash{Symbol => String}]
    attr_reader :prev_inputs

    # @return [Hash{Symbol => String}]
    attr_reader :inputs

    # @return [Hash{Symbol => String}]
    attr_reader :pending_outputs

    # @return [Hash{Symbol => String}]
    attr_reader :outputs

    # @return [Array<Nanoci::Job>]
    attr_reader :jobs

    attr_reader :state

    # Initializes new instance of [Stage]
    # @param src [Hash]
    # @param pipeline [Nanoci::Pipeline]
    # @return [Stage]
    def initialize(src, pipeline)
      @log = Logging.logger[self]
      @tag = src[:tag]
      @pipeline = pipeline
      @triggering_inputs = src[:inputs]
      @inputs = {}
      @jobs = read_jobs(src[:jobs])
      @inputs = {}
      @prev_inputs = {}
      @pending_outputs = {}
      @outputs = {}
      @state = State::IDLE
    end

    # Determines if there are changes in stage triggering inputs
    # @param next_inputs [Hash{Symbol => String}]
    def should_trigger?(next_inputs)
      triggering_inputs.empty? || triggering_inputs.any? do |ti|
        next_inputs.key?(ti) && next_inputs[ti] != inputs.fetch(ti, nil)
      end
    end

    # Runs the jobs with the new inputs
    # @param next_inputs [Hash{Symbol => String}]
    # @param pipeline_engine [Nanoci::PipelineEngine]
    def run(next_inputs, pipeline_engine)
      @log.info "starting stage <#{tag}> with inputs #{next_inputs}"
      @prev_inputs = @inputs
      @inputs = @inputs.merge(next_inputs)
      self.state = Stage::State::RUNNING
      @jobs.each do |j|
        pipeline_engine.run_job(self, j, @inputs, @prev_inputs)
      end
    end

    def finalize
      self.state = Stage::State::IDLE
      @log.info "stage <#{tag}> is completed with outputs #{outputs}"
    end

    def jobs_idle?
      jobs.none? { |j| j.state == Job::State::RUNNING }
    end

    def success?
      jobs.all?(&:success)
    end

    private

    def state=(next_state)
      raise "invalid state #{next_state}" unless State::VALUES.include? next_state

      transition = [@state, next_state]
      @state = next_state

      @log.info "stage <#{tag}> state changed from #{transition[0]} to #{transition[1]}"

      handle_state_transition transition
    end

    def read_jobs(src)
      src.collect { |d| Job.new(d) }
    end

    def handle_state_transition(transition)
      case transition
      in [State::IDLE, State::RUNNING]
        @pending_outputs = {}
      in [State::RUNNING, State::IDLE]
        if success?
          @outputs = @pending_outputs
          @outputs.merge!(@inputs)
        end
        @pending_outputs = {}
        end
    end
  end
end
