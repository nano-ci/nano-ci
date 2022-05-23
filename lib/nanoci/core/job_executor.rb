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

      def schedule_job_execution(project, stage, job, inputs, prev_inputs)
        raise NotImplementedError, 'JobExecutor', 'schedule_job_execution'
      end

      protected

      def publish(stage, job, outputs)
        @job_complete.trigger(JobCompleteEventArgs(stage, job, outputs))
      end
    end
  end
end
