# frozen_string_literal: true

require 'nanoci/core/job_executor'
require 'nanoci/command_host'

module Nanoci
  module Components
    # Executes jobs in current thread
    class InProcessJobExecutor < Nanoci::Core::JobExecutor
      def schedule_job_execution(project, stage, job, inputs, prev_inputs)
        command_host = CommandHost.new(project, stage, job)
        enable_plugins(project, command_host)
        job_outputs = command_host.run(inputs, prev_inputs)
        publish(stage, job, job_outputs)
      end

      # Enables plugins on command host
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
