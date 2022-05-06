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
        @result_publishers = []
        @plugin_host = plugin_host
      end

      def add_result_publisher(job_result_publisher)
        @result_publishers.push(job_result_publisher)
      end

      def schedule_job_execution(project, stage, job, inputs, prev_inputs)
        raise NotImplementedError, 'JobExecutor', 'schedule_job_execution'
      end

      protected

      def publish(stage, job, outputs)
        @result_publishers.each do |p|
          p.publish(stage, job, outputs)
        end
      end
    end
  end
end
