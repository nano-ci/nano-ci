# frozen_string_literal: true

require 'nanoci/core/job_complete_event_args'
require 'nanoci/not_implemented_error'
require 'nanoci/system/event'

module Nanoci
  module Core
    # Executes jobs
    class JobExecutor
      # Job complete event
      # @return [Nanoci::System::Event]
      attr_accessor :job_complete

      # Initializes new instance of [Nanoci::Core::JobExecutor]
      # @param plugin_host [Nanoci::PluginHost]
      def initialize(plugin_host)
        @observers = []
        @plugin_host = plugin_host
        @job_complete = System::Event.new
      end

      # Scheduled execution of a job
      # @param project [Nanoci::Core::Project]
      # @param stage [Nanoci::Core::Stage]
      # @param job [Nanoci::Core::Job]
      # @param inputs [Hash]
      # @param prev_inputs [Hash]
      def schedule_job_execution(project, stage, job, inputs, prev_inputs)
        raise 'method #schedule_job_execution should be implemented in subclass'
      end

      protected

      def publish(stage, job, outputs)
        @job_complete.invoke(self, JobCompleteEventArgs.new(stage, job, outputs))
      end
    end
  end
end
