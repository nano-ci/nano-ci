# frozen_string_literal: true

require_relative '../messaging/topic'
require_relative '../messaging/subscription'
require_relative 'downstream_trigger_rule'
require_relative 'messages/run_stage_message'
require_relative 'messages/stage_complete_message'
require 'nanoci/mixins/logger'

# rubocop:disable Metrics/ClassLength

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
        # @type [Hash{Symbol => Array<Symbol>}]
        @job_executor = job_executor
        @project_repository = project_repository
        # @type [Nanoci::Messaging::Topic]
        @run_stage_topic = topics.fetch(:run_stage_topic)
        # @type [Nanoci::Messaging::Topic]
        @stage_complete_topic = topics.fetch(:stage_complete_topic)
        # @type [Nanoci::Messaging::Topic]
        @job_complete_topic = topics.fetch(:job_complete_topic)
        @running = false
      end

      def start
        log.info 'starting the pipeline engine...'

        @stage_complete_sub = Messaging::Subscription.new('pipeline_engine_stage_complete_sub')
        @stage_complete_topic.attach(@stage_complete_sub)
        @job_complete_sub = Messaging::Subscription.new('pipeline_engine_job_complete_sub')
        @job_complete_topic.attach(@job_complete_sub)
        @run_stage_sub = Messaging::Subscription.new('pipeline_engine_run_stage_sub')
        @run_stage_topic.attach(@run_stage_sub)

        @running = true

        log.info 'the pipeline engine is running'
      end

      def stop
        log.info 'stopping the pipeline engine...'

        @running = false

        @stage_complete_topic.detach(@stage_complete_sub)
        @job_complete_topic.detach(@job_complete_sub)
        @run_stage_topic.detach(@run_stage_sub)

        log.info 'the pipeline engine is stopped'
      end

      def tick(cancellation_token)
        return if cancellation_token.cancellation_requested?

        tick_job_complete_queue
        tick_stage_complete_queue
        tick_run_stage_queue
      end

      # Runs the pipeline on the pipeline engine
      # @param pipeline [Nanoci::Core::Project]
      def run_project(project)
        pipeline = project.pipeline

        log.info "adding pipeline <#{pipeline.tag}> to pipeline engine"

        log.info "pipeline <#{pipeline.tag}> is running"
      end

      # Signals engine that stage is complete
      # @param project_tag [Symbol]
      # @param stage_tag [Symbol] stage
      # @param outputs [Hash{Symbol => String}] stage outputs
      def stage_complete(project_tag, stage_tag, outputs, trigger_rule)
        log.info "pulse signal of completion <#{stage_tag}>"
        project = @project_repository.find_by_tag(project_tag)
        project.pipeline.pipes.fetch(stage_tag, []).each do |next_stage_tag|
          m = Messages::RunStageMessage.new(project_tag, next_stage_tag, outputs, trigger_rule)
          @run_stage_topic.publish(m)
        end
      end

      def run_stage(project, stage, next_inputs)
        jobs = stage.run(next_inputs)
        prepare_jobs_to_run(jobs)
        @project_repository.save_stage(project, stage)
        run_jobs(jobs, project, stage, stage.inputs, stage.prev_inputs) unless jobs.nil?
      end

      def run_jobs(jobs, project, stage, inputs, prev_inputs)
        jobs.each do |x|
          run_job(project, stage, x, inputs, prev_inputs)
        end
      end

      def prepare_jobs_to_run(jobs)
        jobs.each do |x|
          x.state = Job::State::SCHEDULED
        end
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
        project = @project_repository.find_by_tag(project_tag)
        stage = project.pipeline.find_stage(stage_tag)
        job = stage.find_job(job_tag)
        job.finalize(true, outputs)
        stage.job_complete(job)

        @project_repository.save_stage(project, stage)

        return unless stage.jobs_idle?

        m = Messages::StageCompleteMessage.new(project_tag, stage_tag, stage.outputs, stage.downstream_trigger_rule)
        @stage_complete_topic.publish(m)
      end

      private

      def tick_job_complete_queue
        # @type [Nanoci::Messaging::MessageReceipt]
        jcm = @job_complete_sub.pull
        return if jcm.nil?

        # @type [Nanoci::Core::Messages::JobCompleteMessage]
        message = jcm.message
        job_complete(message.project_tag, message.stage_tag, message.job_tag, message.outputs)
        jcm.ack
      end

      def tick_stage_complete_queue
        # @type [Nanoci::Messaging::MessageReceipt]
        scm = @stage_complete_sub.pull
        return if scm.nil?

        # @type [Nanoci::Core::Messages::StageCompleteMessage]
        message = scm.message
        stage_complete(message.project_tag, message.stage_tag, message.outputs, message.downstream_trigger_rule)
        scm.ack
      end

      def tick_run_stage_queue
        # @type [Nanoci::Messaging::MessageReceipt]
        m = @run_stage_sub.pull
        return if m.nil?

        if trigger_stage(m.message.project_tag, m.message.stage_tag, m.message.next_inputs)
          m.ack
        else
          case mp.trigger_rule
          when DownstreamTriggerRule.ignore_if_running then m.ack
          else m.nack
          end
        end
      end

      def trigger_stage(project_tag, stage_tag, inputs)
        project = @project_repository.find_by_tag(project_tag)
        stage = project.pipeline.find_stage(stage_tag)
        return false if stage.state != Stage::State::IDLE

        run_stage(project, stage, inputs)
        true
      end
    end
  end
end

# rubocop:enable Metrics/ClassLength
