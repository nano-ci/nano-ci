# frozen_string_literal: true

require 'concurrent'
require 'concurrent-edge'
require 'ostruct'

require 'nanoci/events/service_events'

module Nanoci
  # PipelineEngine executes pipelines and propagates inputs/outputs
  class PipelineEngine
    # @return [Hash]
    attr_reader :pipelines

    # Initializes new instance of [PipelineEngine]
    def initialize
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
      Concurrent::Promises.future do
        cancellation, @stop_signal = Concurrent.Cancellation.new
        until cancellation.canceled?
          t = @task_queue.pop
          case t.type
          when Events::EXECUTE_JOB
            execute_job(t.stage, t.job, t.inputs, t.prev_inputs)
          when Events::JOB_FINISHED
            finalize_job(t.stage, t.job, t.outputs)
          when Events::STAGE_FINISHED
            finalize_stage(t.stage)
          end
        end
      end
    end

    def stop
      @stop_signal&.resolve
    end

    # Executes pipeline on the engine.
    # @param pipeline [Nanoci::Pipeline]
    def run_pipeline(pipeline)
      raise "duplicate pipeline #{pipeline.tag}" if pipelines.key? pipeline.tag

      add_stages(pipeline)
      add_pipes(pipeline)

      pipelines[pipeline.tag] = pipeline

      start_pipeline(pipeline)
    end

    # Schedules execution of the job
    # @param stage [Nanoci::Stage]
    # @param job [Nanoci::Job]
    # @param inputs [Hash{Symbol => String}]
    # @param prev_inputs [Hash{Symbol => String}]
    def run_job(stage, job, inputs, prev_inputs)
      e = OpenStruct.new(
        type: Events::EXECUTE_JOB,
        stage: stage,
        job: job,
        inputs: inputs,
        prev_inputs: prev_inputs
      )
      @task_queue.push(e)
    end

    # Pulses stage completino signals to pipelines with stage's outputs
    # @param stage_tag [Symbol]
    # @param outputs [Hash{Symbol => String}]
    def pulse(stage_tag, outputs)
      @pipes[stage_tag].each do |stag|
        next_stage = @stages[stag]
        next_stage.state = Stage::State::RUNNING
        next_stage.run(outputs) if next_stage.should_trigger? outputs
      end
    end

    private

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
      job_outputs = {}
      e = OpenStruct.new(
        type: Events::JOB_FINISHED,
        stage: stage,
        job: job,
        outputs: job_outputs
      )
      @task_queue.push(e)
    end

    # Processes results of job execution
    # @param stage [Nanoci::Stage]
    # @param job [Nanoci::Job]
    # @param outputs [Hash{Symbol => String}]
    def finalize_job(stage, job, outputs)
      job.state = Job::State::IDLE
      stage.pending_outputs.merge! outputs
      e = OpenStruct.new(
        type: Events::STAGE_FINISHED,
        stage: stage
      )
      @task_queue.push(e) unless stage.jobs_idle?
    end

    # Processes results of stage execution
    # @param stage [Nanoci::Stage]
    def finalize_stage(stage)
      stage.state = Stage::State::IDLE
      pulse(stage.tag, stage.outputs)
    end
  end
end
