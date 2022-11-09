# frozen_string_literal: true

require 'nanoci/commands/shell'
require 'nanoci/commands/command_output'
require 'nanoci/core/project_repo_locator'
require 'nanoci/mixins/logger'
require 'nanoci/tool_process'

module Nanoci
  # [CommandHost] is a class that executes Job's commands.
  class CommandHost
    include Mixins::Logger

    # Project that's executing on this [Nanoci::CommandHost]
    attr_reader :project

    # Initializes new instance of [CommandHost]
    # @param project [Nanoci::Project]
    # @param stage [Nanoci::Stage]
    # @param job [Nanoci::Job]
    def initialize(project, stage, job)
      @root_work_dir = Config::UCS.instance.build_data_dir
      @project = project
      @stage = stage
      @job = job
      @plugins = []
    end

    def enable_plugin(plugin)
      @plugins.push(plugin)
    end

    # Runs Job's block with given inputs
    # @param inputs [Hash]
    # @param prev_inputs [Hash]
    def run(inputs, prev_inputs)
      block = @job.body
      case block.arity
      when 0 then instance_exec(&block)
      when 1 then instance_exec(inputs, &block)
      when 2 then instance_exec(inputs, prev_inputs, &block)
      else raise ArgumentError, "job body block has invalid number of arguments (got #{block.arity}, expected 0..2)"
      end
    end

    # Executes passed command line
    def execute_shell(line)
      job_work_dir = work_dir(@stage, @job)
      job_env = env(@job)
      log.debug { "shell: \"#{line}\" at \"#{job_work_dir}\"" }
      FileUtils.mkpath job_work_dir
      tool = ToolProcess.run("sh -c \"#{line}\"", chdir: job_work_dir, env: job_env).wait
      log.debug { "shell: exit code - #{tool.status_code}" }
      Commands::CommandOutput.new(tool.status_code, tool.output, tool.error)
    end

    def method_missing(method_name, *args, &block)
      plugin = @plugins.select { |i| i.respond_to? method_name }.first
      args.unshift(self, project)
      plugin.send(method_name, *args, &block)
    end

    def respond_to_missing?(method_name, include_private)
      @plugins.each do |i|
        return true if i.respond_to?(method_name, include_private)
      end
      super
    end

    private

    def shell
      Commands::Shell.new(self)
    end

    def repos
      Core::ProjectRepoLocator.new(@project)
    end

    # Returns work directory for the job
    # @param stage [Nanoci::Stage]
    # @param job [Nanoci::Job]
    def work_dir(stage, job)
      File.join(@root_work_dir, stage.tag.to_s, job.tag.to_s, job.work_dir)
    end

    def env(job)
      job_env = job.env

      job_env = case job_env
                when nil then nil
                when Hash then job_env
                when Proc then job_env.call
                end
      raise 'env is not a Hash' unless job_env.nil? || job_env.is_a?(Hash)

      job_env
    end
  end
end
