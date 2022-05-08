# frozen_string_literal: true

require 'nanoci/not_implemented_error'

module Nanoci
  module Core
    # Executes jobs
    class JobExecutor
      # Initializes new instance of [Nanoci::Core::JobExecutor]
      # @param job_result_publisher [Nanoci::Core::JobResultPublisher]
      # @param plugin_host [Nanoci::PluginHost]
      def initialize(plugin_host)
        @observers = []
        @plugin_host = plugin_host
      end

      def add_observer(job_result_publisher)
        @observers.push(job_result_publisher)
      end

      def schedule_job_execution(project, stage, job, inputs, prev_inputs)
        raise NotImplementedError, 'JobExecutor', 'schedule_job_execution'
      end

      protected

      def publish(stage, job, outputs)
        @observers.each do |p|
          p.publish(stage, job, outputs)
        end
      end
    end
  end
end
