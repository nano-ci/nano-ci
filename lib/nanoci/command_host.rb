# frozen_string_literal: true

require 'nanoci/commands/shell'
require 'nanoci/commands/command_output'
require 'nanoci/tool_process'

module Nanoci
  # [CommandHost] is a class that executes Job's commands.
  class CommandHost
    # Initializes new instance of [CommandHost]
    # @param stage [Nanoci::Stage]
    # @param job [Nanoci::Job]
    def initialize(stage, job)
      @root_work_dir = Config::UCS.instance.build_data_dir
      @stage = stage
      @job = job
    end

    # Runs Job's block with given inputs
    # @param inputs [Hash]
    # @param prev_inputs [Hash]
    # @yield [inputs, prev_inputs] Executes job body
    # @yieldparam inputs [Hash]
    # @yieldparam prev_inputs [Hash]
    def run(inputs, prev_inputs, &block)
      case block.arity
      when 0
        instance_exec(&block)
      when 1
        instance_exec(inputs, &block)
      when 2
        instance_exec(inputs, prev_inputs, &block)
      else
        raise ArgumentError, "job body block has invalid number of arguments (got #{block.arity}, expected 0..2)"
      end
    end

    # Executes passed command line
    def execute_shell(line)
      job_work_dir = work_dir(@stage, @job)
      FileUtils.mkpath job_work_dir unless Dir.exist? job_work_dir
      tool = ToolProcess.run("sh -c \"#{line}\"", chdir: job_work_dir).wait
      Commands::CommandOutput.new(tool.status_code, tool.output, tool.error)
    end

    private

    def shell
      Commands::Shell.new(self)
    end

    # Returns work directory for the job
    # @param stage [Nanoci::Stage]
    # @param job [Nanoci::Job]
    def work_dir(stage, job)
      File.join(@root_work_dir, stage.tag.to_s, job.tag.to_s, job.work_dir)
    end
  end
end
