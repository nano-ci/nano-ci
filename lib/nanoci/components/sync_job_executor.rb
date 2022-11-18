# frozen_string_literal: true

require 'nanoci/core/job_executor'
require 'nanoci/command_host'

require_relative '../plugins/extension_point'

module Nanoci
  module Components
    # Executes jobs in current thread
    class SyncJobExecutor < Nanoci::Core::JobExecutor
      include Nanoci::Mixins::Logger

      def schedule_job_execution(project, stage, job, inputs, prev_inputs)
        log.info("executing job #{job} with inputs #{inputs}")
        extension_point = build_extension_point(project)
        command_host = CommandHost.new(project, stage, job, extension_point)
        job_outputs = command_host.run(inputs, prev_inputs)
        publish(project, stage, job, job_outputs)
      rescue StandardError => e
        log.error(error: e) { "failed to execute job <#{project}.#{stage}.#{job}>" }
      end

      private

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
