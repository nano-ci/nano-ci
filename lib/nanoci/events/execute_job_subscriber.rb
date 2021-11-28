# frozen_string_literal: true

require 'nanoci/command_host'
require 'nanoci/errors/job_error'
require 'nanoci/events/job_finished_event'
require 'nanoci/events/subscriptions'
require 'nanoci/events/topics'
require 'nanoci/messaging/subscriber'
require 'nanoci/mixins/logger'

module Nanoci
  module Events
    class ExecuteJobSubscriber < Nanoci::Messaging::Subscriber
      include Nanoci::Mixins::Logger

      def initialize(topic_factory, subscription_factory)
        # @type [Nanoci::Messaging::Topic]
        @job_finished_topic = topic_factory.get_topic Topics::JOB_FINISHED

        subscription = subscription_factory.get_subscription Subscriptions::EXECUTE_JOB
        super(subscription)
      end

      # Handles event ExecuteJobEvent
      # @param msg [Nanoci::Events::ExecuteJobEvent]
      def handle_message(msg)
        project = msg.project
        stage = msg.stage
        job = msg.job
        inputs = msg.inputs
        prev_inputs = msg.prev_inputs

        execute_job(project, stage, job, inputs, prev_inputs)
      end

      # Executes job
      # @param project [Nanoci::Project]
      # @param stage [Nanoci::Stage]
      # @param job [Nanoci::Job]
      # @param inputs [Hash{Symbol => String}]
      # @param prev_inputs [Hash{Symbol => String}]
      def execute_job(project, stage, job, inputs, prev_inputs)
        log.info "executing job <#{stage.tag}.#{job.tag}>"
        is_handled = false
        begin
          execute_job_body(project, stage, job, inputs, prev_inputs)
          is_handled = true
        rescue Errors::JobError => e
          log.error "failed to execute job <#{stage.tag}.#{job.tag}> due to a job error"
          log.error e
          is_handled = true
        rescue StandardError => e
          log.error "failed to execute job <#{stage.tag}.#{job.tag}> due to an unexected error"
          log.error e
        end

        log.info "finished executing job <#{stage.tag}.#{job.tag}>"
        is_handled
      end

      # @param project [Nanoci::Project]
      def execute_job_body(project, stage, job, inputs, prev_inputs)
        command_host = CommandHost.new(project, stage, job)
        enable_plugins(project, command_host)
        job_outputs = command_host.run(inputs, prev_inputs)
        job_finished_event = JobFinishedEvent.new(project, stage, job, job_outputs, true)
        @job_finished_topic.publish(job_finished_event)
      rescue Errors::JobError => e
        job_finished_event = JobFinishedEvent.new(project, stage, job, nil, false)
        @job_finished_topic.publish(job_finished_event)

        raise e
      end

      # @param project [Nanoci::Project]
      # @param command_host [Nanoci::CommandHost]
      def enable_plugins(project, command_host)
        project.plugins.each_key do |k|
          plugin = @plugin_host.get_plugin(k)
          raise "plugin <#{k}> is missing" if plugin.nil?

          command_host.enable_plugin(plugin)
        end
      end
    end
  end
end
