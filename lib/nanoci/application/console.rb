# frozen_string_literal: true

require 'nanoci/components/sync_job_executor'
require 'nanoci/config/ucs'
require 'nanoci/core/pipeline_engine'
require 'nanoci/log'
require 'nanoci/mixins/logger'
require 'nanoci/plugin_host'
require 'nanoci/project_repository'
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
        log.info 'nano-ci is starting...'

        setup_components(argv)

        log.info 'nano-ci is running'

        run

        log.info 'nano-ci is stopping...'

        @pipeline_engine.stop

        log.info 'nano-ci is stopped'
      end

      private

      def setup_components(argv)
        Config::UCS.initialize(argv)

        ucs = Config::UCS.instance

        @project_repository = ProjectRepository.new
        @plugin_host = load_plugins(File.expand_path(ucs.plugins_path))
        @job_executor = Components::SyncJobExecutor.new(@plugin_host)
        @pipeline_engine = Core::PipelineEngine.new(@job_executor, @project_repository)
        @job_executor.job_complete.attach do |_, e|
          @pipeline_engine.job_complete(e.project_tag, e.stage_tag, e.job_tag, e.outputs)
        end
      end

      # runs a nano-ci main service
      # @param project [Nanoci::Project]
      # @return [void]
      def run
        project = load_project(Config::UCS.instance.project)
        @project_repository.add(project)
        @pipeline_engine.run_project(project)

        keep_running = true

        trap('INT') do
          keep_running = false
        end

        sleep(0.1) while keep_running
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
