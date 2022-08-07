# frozen_string_literal: true

require 'nanoci/mixins/logger'

module Nanoci
  module Core
    # PipelineEngine executes pipelines and propagates inputs/outputs
    class PipelineEngine
      include Nanoci::Mixins::Logger

      # Initializes new instance of [Nanoci::Core::PipelineEngine]
      # @param job_executor [Nanoci::Core::JobExecutor]
      def initialize(job_executor)
        @pipelines = []
        @stages = {}
        # @type [Hash{Symbol => Array<Symbol>}]
        @pipes = Hash.new { |h, k| h[k] = [] }
        @job_executor = job_executor
      end

      # Runs the pipeline on the pipeline engine
      # @param pipeline [Nanoci::Core::Pipeline]
      def run_pipeline(pipeline)
        raise "duplicate pipeline #{pipeline.tag}" if duplicate? pipeline

        log.info "adding pipeline <#{pipeline.tag}> to pipeline engine"

        # TODO: process validation results
        pipeline.validate

        add_stages(pipeline)

        @pipelines.push(pipeline)

        start_pipeline_triggers(pipeline)

        log.info "pipeline <#{pipeline.tag}> is running"
      end

      # Signals engine that stage is complete
      # @param stage [Nanoci::Core::Stage] stage
      # @param outputs [Hash{Symbol => String}] stage outputs
      def stage_complete(stage, outputs)
        log.info "pulse signal of completion <#{stage.tag}>"
        @pipes[stage.tag].each do |next_stage|
          next_stage.run(outputs, self) if next_stage.should_trigger? outputs
        rescue StandardError => e
          log.error(error_log_event(
                      "failed to run next stage <#{next_stage.tag}> after signal of completion <#{stage.tag}>",
                      reason: e
                    ))
        end
      end

      # Schedules execution of the job
      # @param stage [Nanoci::Stage]
      # @param job [Nanoci::Job]
      # @param inputs [Hash{Symbol => String}]
      # @param prev_inputs [Hash{Symbol => String}]
      def run_job(stage, job, inputs, prev_inputs)
        @job_executor.schedule_job_execution(stage, job, inputs, prev_inputs)
      end

      def job_complete(stage, job, outputs)
        job.finalize(true, outputs)
        stage.job_complete(job)
        stage_complete(stage, stage.outputs) if stage.jobs_idle?
      rescue StandardError => e
        log.error(error_log_event(
                    "failed to pulse stage <#{stage.tag}> completion signal",
                    reason: e
                  ))
      end

      private

      # Checks for duplicate pipeline
      # @param pipeline [Nanoci::Core::Pipeline]
      # @return Boolean true if there was another pipeline with the same tag; false otherwise
      def duplicate?(pipeline)
        @pipelines.any? { |x| x.tag == pipeline.tag }
      end

      # Starts the pipeline
      # @param pipeline [Nanoci::Pipeline]
      def start_pipeline_triggers(pipeline)
        # @param t [Nanoci::Trigger]
        pipeline.triggers.each(&:run)
      end

      def add_stages(pipeline)
        # @param s [Nanoci::Stage]
        pipeline.stages.each do |s|
          raise ArgumentError, "duplicate stage #{s.tag}" if @stages.key? s.tag

          @stages[s.tag] = s
        end

        pipeline.pipes.each do |(s_tag, v)|
          v.each do |t_tag|
            @pipes[s_tag].push(@stages[t_tag])
          end
        end
      end
    end
  end
end
