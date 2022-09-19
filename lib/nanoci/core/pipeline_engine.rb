# frozen_string_literal: true

require 'nanoci/mixins/logger'

module Nanoci
  module Core
    # PipelineEngine executes pipelines and propagates inputs/outputs
    class PipelineEngine
      include Nanoci::Mixins::Logger

      # Initializes new instance of [Nanoci::Core::PipelineEngine]
      # @param job_executor [Nanoci::Core::JobExecutor]
      # @param project_repository [Nanoci::ProjectRepository]
      def initialize(job_executor, project_repository)
        # @type [Hash{Symbol => Array<Symbol>}]
        @job_executor = job_executor
        @project_repository = project_repository
      end

      def start
        log.info 'starting the pipeline engine...'
        # TODO: add code
        log.info 'the pipeline engine is running'
      end

      def stop
        log.info 'stopping the pipeline engine...'
        # TODO: add code
        log.info 'the pipeline engine is stopped'
      end

      # Runs the pipeline on the pipeline engine
      # @param pipeline [Nanoci::Core::Project]
      def run_project(project)
        pipeline = project.pipeline

        log.info "adding pipeline <#{pipeline.tag}> to pipeline engine"

        start_pipeline_triggers(project)

        log.info "pipeline <#{pipeline.tag}> is running"
      end

      # Signals engine that stage is complete
      # @param project_tag [Symbol]
      # @param stage_tag [Symbol] stage
      # @param outputs [Hash{Symbol => String}] stage outputs
      def stage_complete(project_tag, stage_tag, outputs)
        log.info "pulse signal of completion <#{stage_tag}>"
        project = @project_repository.find_by_tag(project_tag)
        project.pipeline.pipes.fetch(stage_tag, []).each do |next_stage_tag|
          next_stage = project.pipeline.find_stage(next_stage_tag)
          run_stage(project, next_stage, outputs)
        end
      end

      def run_stage(project, stage, next_inputs)
        jobs = stage.run(next_inputs)
        @project_repository.save_stage(project, stage)
        run_jobs(jobs, project, stage, stage.inputs, stage.prev_inputs)
      end

      def run_jobs(jobs, project, stage, inputs, prev_inputs)
        jobs.each do |x|
          run_job(project, stage, x, inputs, prev_inputs)
        end
      end

      # Schedules execution of the job
      # @param project [Nanoci::Project]
      # @param stage [Nanoci::Stage]
      # @param job [Nanoci::Job]
      # @param inputs [Hash{Symbol => String}]
      # @param prev_inputs [Hash{Symbol => String}]
      def run_job(project, stage, job, inputs, prev_inputs)
        @job_executor.schedule_job_execution(project, stage, job, inputs, prev_inputs)
      end

      def job_complete(project_tag, stage_tag, job_tag, outputs)
        project = @project_repository.find_by_tag(project_tag)
        stage = project.pipeline.find_stage(stage_tag)
        job = stage.find_job(job_tag)
        job.finalize(true, outputs)
        stage.job_complete(job)

        @project_repository.save_stage(project, stage)

        stage_complete(project_tag, stage_tag, stage.outputs) if stage.jobs_idle?
      end

      private

      # Starts the pipeline
      # @param pipeline [Nanoci::Core::Project]
      def start_pipeline_triggers(project)
        # @param t [Nanoci::Trigger]
        project.pipeline.triggers.each do |t|
          t.pulse.attach do |s, e|
            stage_complete(project.tag, s.full_tag, e.outputs)
          end
          t.run
        end
      end
    end
  end
end
