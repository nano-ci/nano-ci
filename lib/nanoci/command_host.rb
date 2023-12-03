# frozen_string_literal: true

require 'nanoci/commands/shell'
require 'nanoci/core/project_repo_locator'
require 'nanoci/mixins/logger'

require_relative 'shell_host'

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
    # @param extension_point [Nanoci::Plugins::ExtensionPoint]
    def initialize(project, stage, job, extension_point)
      @root_work_dir = Config::UCS.instance.build_data_dir
      @project = project
      @stage = stage
      @job = job
      @extension_point = extension_point
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
    def execute_shell(line, env: nil)
      ShellHost.new.run(line, work_dir(@stage, @job), env: build_job_env(@job, env))
    end

    def method_missing(method_name, *args, &block)
      proc = @extension_point.find_command(method_name)
      raise "command #{method_name} not found" if proc.nil?

      args.unshift(self, project)
      proc.call(*args, &block)
    end

    def respond_to_missing?(method_name, include_private)
      @extension_point.command?(method_name) || super
    end

    private

    def sh(line) = execute_shell(line)

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

    # Builds environment for the job
    # @param job [Nanoci::Core::Job]
    def build_job_env(job, command_env)
      job_env = job.env

      job_env = case job_env
                when nil then {}
                when Hash then job_env
                when Proc then job_env.call
                end
      raise 'env is not a Hash' unless job_env.nil? || job_env.is_a?(Hash)

      job_env = job_env.merge(command_env) unless command_env.nil?
      job_env
    end
  end
end
