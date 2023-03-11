# frozen_string_literal: true

require_relative '../messaging/topic'
require_relative '../messaging/subscription'
require_relative 'domain_events'
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
        # @type [Hash{Symbol => Array<Symbol>}]
        @job_executor = job_executor
        @project_repository = project_repository
        # @type [Nanoci::Messaging::Topic]
        @job_complete_topic = topics.fetch(:job_complete_topic)
        @running = false
        @domain_events_map = {
          JobScheduledEvent => [method(:on_job_scheduled_event)]
        }
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

      # Runs the pipeline on the pipeline engine
      # @param pipeline [Nanoci::Core::Project]
      def run_project(project)
        pipeline = project.pipeline

        log.info "adding pipeline <#{pipeline.tag}> to pipeline engine"

        log.info "pipeline <#{pipeline.tag}> is running"
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
        project.job_complete(stage_tag, job_tag, outputs)

        @project_repository.save(project)

        dispatch_domain_events
      end

      def trigger_fired(project_tag, trigger_tag, outputs)
        project = @project_repository.find_by_tag(project_tag)
        project.trigger_fired(trigger_tag, outputs)

        @project_repository.save(project)

        dispatch_domain_events
      end

      private

      def dispatch_domain_events
        until DomainEvents.instance.empty?
          e = DomainEvents.instance.shift
          raise "unknown domain event class #{e.class}" unless @domain_events_map.key?(e.class)

          @domain_events_map[e.class].each do |h|
            h.call(e)
          end
        end
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

      def on_job_scheduled_event(event)
        project = @project_repository.find_by_tag(event.project_tag)
        stage = project.pipeline.find_stage(event.stage_tag)
        job = stage.find_job(event.job_tag)
        run_job(project, stage, job, stage.inputs, stage.prev_inputs)
      end
    end
  end
end
