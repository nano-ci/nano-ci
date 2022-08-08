# frozen_string_literal: true

require 'nanoci/components/sync_job_executor'
require 'nanoci/config/ucs'
require 'nanoci/core/pipeline_engine'
require 'nanoci/mixins/logger'
require 'nanoci/plugin_host'
require 'nanoci/dsl/script_dsl'
require 'nanoci/triggers/interval_trigger_dsl'

module Nanoci
  module Application
    # Entry point to nano-ci in console mode
    # Non-cluster
    # Single thread
    class Console
      include Nanoci::Mixins::Logger
      def main(argv)
        log.info 'nano-ci starting...'

        Config::UCS.initialize(argv)
        setup_components
        project = load_project(Config::UCS.instance.project)

        log.info 'nano-ci is running'

        run(project)
      end

      private

      def setup_components
        ucs = Config::UCS.instance

        @plugin_host = load_plugins(File.expand_path(ucs.plugins_path))
        @job_executor = Components::SyncJobExecutor.new(@plugin_host)
        @pipeline_engine = Core::PipelineEngine.new(@job_executor)
        @job_executor.job_complete.attach do |_, e|
          @pipeline_engine.job_complete(e.stage, e.job, e.outputs)
        end
      end

      # runs a nano-ci main service
      # @param project [Nanoci::Project]
      # @return [void]
      def run(project)
        @pipeline_engine.run_pipeline(project.pipeline)
        @pipeline_engine.run.wait!
      end

      def load_plugins(plugins_path)
        log.debug "loading plugins from #{plugins_path}..."
        # TODO: pass plugins_path to PluginHost
        PluginHost.new
      end

      # Reads project from the file
      # @param project_path [String]
      # @return [Nanoci::Project]
      def load_project(project_path)
        log.info "reading project definition from #{project_path}..."
        script_text = File.read(project_path)
        log.debug "input script text:\n#{script_text}"
        script_dsl = DSL::ScriptDSL.from_string(script_text)
        project_dsl = script_dsl.projects[0]
        log.info "read project #{project_dsl.tag}"
        project_dsl.build
      end
    end
  end
end
