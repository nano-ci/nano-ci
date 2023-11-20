# frozen_string_literal: true

require_relative '../messaging/topic'
require_relative '../messaging/subscription'
require_relative 'downstream_trigger_rule'
require_relative 'messages/run_stage_message'
require_relative 'messages/stage_complete_message'
require 'nanoci/mixins/logger'

module Nanoci
  module Core
    # PipelineEngine executes pipelines and propagates inputs/outputs
    class PipelineEngine
      include Nanoci::Mixins::Logger

      # Initializes new instance of [Nanoci::Core::PipelineEngine]
      # @param job_executor [Nanoci::Core::JobExecutor]
      # @param project_repository [Nanoci::ProjectRepository]
      # @param topics [Hash{Symbol=>Nanoci::Messaging::Topic}]
      def initialize(job_executor, project_repository, topics)
        @projects = {}
        @job_executor = job_executor
        @project_repository = project_repository
        # @type [Nanoci::Messaging::Topic]
        @job_complete_topic = topics.fetch(:job_complete_topic)
        @running = false
      end

      def start
        log.info 'starting the pipeline engine...'

        @job_complete_sub = Messaging::Subscription.new('pipeline_engine_job_complete_sub')
        @job_complete_topic.attach(@job_complete_sub)

        @running = true

        log.info 'the pipeline engine is running'
      end

      def stop
        log.info 'stopping the pipeline engine...'

        @running = false

        @job_complete_topic.detach(@job_complete_sub)

        log.info 'the pipeline engine is stopped'
      end

      def tick(cancellation_token)
        return if cancellation_token.cancellation_requested?

        tick_job_complete_queue
      end

      # Runs the project on the pipeline engine
      # @param project [Nanoci::Core::Project]
      def run_project(project)
        log.info "preparing to run the project #{project}"

        if @projects.key? project.tag
          log.warn "duplicate run of a project #{project}, ignoring..."
          return
        end
        @projects[project.tag] = project

        cancel_dnf_jobs(project)

        project.pipeline.stages.each(&:finalize)

        @project_repository.save(project)

        log.info "project #{project} is running"
      end

      # Schedules execution of the job
      # @param project [Nanoci::Project]
      # @param stage [Nanoci::Stage]
      # @param job [Nanoci::Job]
      # @param inputs [Hash{Symbol => String}]
      # @param prev_inputs [Hash{Symbol => String}]
      def run_job(project, stage, job, inputs, prev_inputs)
        job.state = Job::State::RUNNING
        @job_executor.schedule_job_execution(project, stage, job, inputs, prev_inputs)
      end

      def job_complete(project_tag, stage_tag, job_tag, outputs)
        project = @projects.fetch(project_tag)
        project.job_complete(stage_tag, job_tag, outputs)

        @project_repository.save(project)

        run_scheduled_jobs
      end

      def trigger_fired(project_tag, trigger_tag, outputs)
        project = @projects.fetch(project_tag)
        project.trigger_fired(trigger_tag, outputs)

        @project_repository.save(project)

        run_scheduled_jobs
      end

      private

      def run_scheduled_jobs
        @projects.each_value do |p|
          p.scheduled_jobs.each do |j|
            run_job(p, j.stage, j, j.stage.inputs, j.stage.prev_inputs)
          end
        end
      end

      def cancel_dnf_jobs(project)
        log.info 'checking for DNF jobs...'

        project.pipeline.stages
               .flat_map(&:jobs)
               .select { |j| job_running?(j) }
               .each do |job|
          log.info "job #{job} didn't finish, cancelling..."
          project.job_canceled(job.stage_tag, job.tag)
        end
      end

      def job_running?(job)
        job.running? && !@job_executor.job_running?(job)
      end

      def tick_job_complete_queue
        # @type [Nanoci::Messaging::MessageReceipt]
        jcm = @job_complete_sub.pull
        return if jcm.nil?

        # @type [Nanoci::Core::Messages::JobCompleteMessage]
        message = jcm.message
        job_complete(message.project_tag, message.stage_tag, message.job_tag, message.outputs)
        jcm.ack
      end
    end
  end
end
