# frozen_string_literal: true

require 'nanoci/commands/shell'
require 'nanoci/commands/command_output'
require 'nanoci/tool_process'

module Nanoci
  # [CommandHost] is a class that executes Job's commands.
  class CommandHost
    # Runs Job's block with given inputs
    def run(inputs, &block)
      instance_exec(inputs, &block)
    end

    # Executes passed command line
    def execute_shell(line)
      tool = ToolProcess.run("sh -c \"#{line}\"")
      Commands::CommandOutput.new(tool.status_code, tool.output, tool.error)
    end

    private

    def shell
      Commands::Shell.new(self)
    end
  end
end
