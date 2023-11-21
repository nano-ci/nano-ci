# frozen_string_literal: true

require 'nanoci/core/job_executor'
require 'nanoci/command_host'

require_relative '../plugins/extension_point'

module Nanoci
  module Components
    # Executes jobs in current thread
    class SyncJobExecutor < Nanoci::Core::JobExecutor
      include Nanoci::Mixins::Logger

      def schedule_job_execution(job, inputs, prev_inputs)
        super
        log.info("executing job #{job} with inputs #{inputs}")
        job_outputs = execute_job(job, inputs, prev_inputs)
        job_succeeded(job, job_outputs)
      rescue StandardError => e
        job_failed(job, {}, e)
      end

      def schedule_hook_execution(job, inputs, prev_inputs)
        super
        execute_job(job, inputs, prev_inputs)
      rescue StandardError => e
        log.error(error: e) { "failed to execute hook #{job}" }
      end

      private

      def execute_job(job, inputs, prev_inputs)
        extension_point = build_extension_point(job.project)
        command_host = CommandHost.new(job.project, job.stage, job, extension_point)
        command_host.run(inputs, prev_inputs)
      end

      # Builds extension point with plugins requested by the project
      # @param project [Nanoci::Core::Project]
      # @return [Nanoci::Plugins::ExtensionPoint]
      def build_extension_point(project)
        extension_point = Plugins::ExtensionPoint.new
        project.plugins.each_key do |k|
          plugin = @plugin_host.get_plugin(k)
          raise "plugin <#{k}> is missing" if plugin.nil?

          plugin.augment(extension_point)
        end
        extension_point
      end
    end
  end
end
