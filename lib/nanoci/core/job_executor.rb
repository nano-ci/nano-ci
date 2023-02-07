# frozen_string_literal: true

require 'nanoci/core/job_complete_event_args'
require 'nanoci/mixins/logger'
require 'nanoci/not_implemented_error'
require 'nanoci/system/event'

require_relative 'messages/job_complete_message'
require_relative '../messaging/topic'

module Nanoci
  module Core
    # Executes jobs
    class JobExecutor
      include Nanoci::Mixins::Logger

      # Initializes new instance of [Nanoci::Core::JobExecutor]
      # @param plugin_host [Nanoci::PluginHost]
      def initialize(plugin_host, job_complete_topic)
        @observers = []
        @plugin_host = plugin_host
        @job_complete_topic = job_complete_topic
      end

      # Scheduled execution of a job
      # @param project [Nanoci::Core::Project]
      # @param stage [Nanoci::Core::Stage]
      # @param job [Nanoci::Core::Job]
      # @param inputs [Hash]
      # @param prev_inputs [Hash]
      def schedule_job_execution(_project, _stage, _job, _inputs, _prev_inputs)
        raise 'method #schedule_job_execution should be implemented in subclass'
      end

      def schedule_hook_execution(_project, _stage, _job, _inputs, _prev_inputs)
        raise 'method #schedule_hook_execution should be implemented in subclass'
      end

      protected

      def job_succeeded(project, stage, job, outputs)
        m = Messages::JobCompleteMessage.new(project.tag, stage.tag, job.tag, outputs)
        @job_complete_topic.publish(m)
      end

      # Job failure handler
      # @param project [Nanoci::Core::Project]
      # @param stage [Nanoci::Core::Stage]
      # @param job [Nanoci::Core::Job]
      # @param outputs [Hash]
      # @param error [StandardError]
      def job_failed(project, stage, job, _outputs, error)
        log.error(error: error) { "failed to execute job <#{project}.#{stage}.#{job}>" }
        after_failure_hook = stage.hook_after_failure
        return if after_failure_hook.nil?

        log.debug { "job #{job} has hook <after_failure>. running the hook..." }
        hook_job_tag = "#{job.tag}_hook_after_failure".to_sym
        hook_job = Job.new(tag: hook_job_tag, body: after_failure_hook, work_dir: job.work_dir, env: job.env)
        schedule_hook_execution(project, stage, hook_job, {}, {})
      end
    end
  end
end
