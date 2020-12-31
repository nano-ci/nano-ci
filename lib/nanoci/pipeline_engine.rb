# frozen_string_literal: true

require 'concurrent'
require 'concurrent-edge'
require 'logging'
require 'ostruct'

require 'nanoci/events/service_events'

module Nanoci
  # PipelineEngine executes pipelines and propagates inputs/outputs
  class PipelineEngine
    # @return [Hash]
    attr_reader :pipelines

    # Initializes new instance of [PipelineEngine]
    def initialize
      @log = Logging.logger[self]
      # @type [Hash]
      @pipelines = {}
      # @type [Hash]
      @stages = {}
      # @type [Hash{Symbol => Array<Symbol>}]
      @pipes = Hash.new { |h, k| h[k] = [] }
      @task_queue = Concurrent::Promises::Channel.new
    end

    # Starts the engine
    def run
      @log.info 'pipeline engine is running'
      Concurrent::Promises.future do
        cancellation, @stop_signal = Concurrent::Cancellation.new
        until cancellation.canceled?
          t = @task_queue.pop
          begin
            case t.type
            when Events::EXECUTE_JOB
              execute_job(t.stage, t.job, t.inputs, t.prev_inputs)
            when Events::JOB_FINISHED
              finalize_job(t.stage, t.job, t.outputs)
            when Events::STAGE_FINISHED
              finalize_stage(t.stage)
            end
          rescue StandardError => e
            @log.error "failed to process event <#{t.type}>"
            @log.error e
          end
        end
        @log.info 'pipeline engine is stopped'
      end
    end

    def stop
      @stop_signal&.resolve
    end

    # Executes pipeline on the engine.
    # @param pipeline [Nanoci::Pipeline]
    def run_pipeline(pipeline)
      raise "duplicate pipeline #{pipeline.tag}" if pipelines.key? pipeline.tag

      @log.info "adding pipeline <#{pipeline.tag}> to pipeline engine"

      # TODO: process validation results
      validate_pipeline(pipeline)

      add_stages(pipeline)
      add_pipes(pipeline)

      pipelines[pipeline.tag] = pipeline

      start_pipeline(pipeline)

      @log.info "pipeline <#{pipeline.tag}> is running"
    end

    # Schedules execution of the job
    # @param stage [Nanoci::Stage]
    # @param job [Nanoci::Job]
    # @param inputs [Hash{Symbol => String}]
    # @param prev_inputs [Hash{Symbol => String}]
    def run_job(stage, job, inputs, prev_inputs)
      @log.info "putting job <#{stage.tag}.#{job.tag}> to execution queue"
      e = OpenStruct.new(
        type: Events::EXECUTE_JOB,
        stage: stage,
        job: job,
        inputs: inputs,
        prev_inputs: prev_inputs
      )
      @task_queue.push(e)
      @log.info "job <#{stage.tag}.#{job.tag}> is queued"
    end

    # Pulses stage completino signals to pipelines with stage's outputs
    # @param stage_tag [Symbol]
    # @param outputs [Hash{Symbol => String}]
    def pulse(stage_tag, outputs)
      @log.info "pulse signal of completion <#{stage_tag}>"
      (@pipes[stage_tag].map { |s| @stages[s] }).each do |next_stage|
        next_stage.run(outputs, self) if next_stage.should_trigger? outputs
      rescue StandardError => e
        @log.error "failed to run next stage <#{next_stage.tag}> after signal of completion <#{stage_tag}>"
        @log.error e
      end
    rescue StandardError => e
      @log.error "failed to pulse stage <#{stage_tag}> completion signal"
      @log.error e
    end

    private

    # Validates the pipeline
    # @param pipeline [Nanoci::Pipeline]
    # @return Boolean
    def validate_pipeline(pipeline)
      valid = true
      pipeline.triggers.each do |t|
        unless pipeline.pipes.key?(t.full_tag)
          @log.warn("trigger #{t.tag} output is not connected to any of stage inputs")
          valid = false
        end
      end
      pipeline.pipes.each_pair do |k, v|
        has_trigger = pipeline.triggers.any? { |t| t.full_tag == k }
        has_stage = pipeline.stages.any? { |s| s.tag == k }
        unless has_trigger || has_stage
          @log.warn("invalid pipe - stage #{k} does not exist")
          valid = false
        end
        v.each do |i|
          has_trigger = pipeline.triggers.any? { |t| t.full_tag == i }
          has_stage = pipeline.stages.any? { |s| s.tag == i }
          unless has_trigger || has_stage
            @log.warn("invalid pipe - stage #{i} does not exist")
            valid = false
          end
        end
      end
      valid
    end

    # Starts the pipeline
    # @param pipeline [Nanoci::Pipeline]
    def start_pipeline(pipeline)
      # @param t [Nanoci::Trigger]
      pipeline.triggers.each { |t| t.run(self) }
    end

    def add_stages(pipeline)
      # @param s [Nanoci::Stage]
      # @param m [Hash]
      pipeline.stages.each_with_object(@stages) do |s, m|
        raise "duplicate stage #{s.tag}" if m.key? s.tag

        m[s.tag] = s
      end
    end

    def add_pipes(pipeline)
      # @param k [Symbol]
      # @param v [Array<Symbol>]
      # @param m [Hash{Symbol => Array<Symbol>}]
      pipeline.pipes.each_with_object(@pipes) do |(k, v), m|
        m[k].push(*v)
      end
    end

    # Executes job
    # @param stage [Nanoci::Stage]
    # @param job [Nanoci::Job]
    # @param inputs [Hash{Symbol => String}]
    # @param prev_inputs [Hash{Symbol => String}]
    def execute_job(stage, job, inputs, prev_inputs)
      # TODO: implement this method in scope of issue #5
      @log.info "executing job <#{stage.tag}.#{job.tag}>"
      job_outputs = {}
      e = OpenStruct.new(
        type: Events::JOB_FINISHED,
        stage: stage,
        job: job,
        outputs: job_outputs
      )
      @task_queue.push(e)
      @log.info "job <#{stage.tag}.#{job.tag}> execution is completed"
    end

    # Processes results of job execution
    # @param stage [Nanoci::Stage]
    # @param job [Nanoci::Job]
    # @param outputs [Hash{Symbol => String}]
    def finalize_job(stage, job, outputs)
      @log.info "finalizing job <#{stage.tag}.#{job.tag}> execution"
      job.state = Job::State::IDLE
      stage.pending_outputs.merge! outputs
      e = OpenStruct.new(
        type: Events::STAGE_FINISHED,
        stage: stage
      )
      @log.info "job <#{stage.tag}.#{job.tag}> is completed"
      @task_queue.push(e) if stage.jobs_idle?
    end

    # Processes results of stage execution
    # @param stage [Nanoci::Stage]
    def finalize_stage(stage)
      @log.info "finalizing stage <#{stage.tag}> execution"
      stage.finalize
      pulse(stage.tag, stage.outputs)
    end
  end
end
