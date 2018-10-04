# frozen_string_literal: true

require 'nanoci/common_vars'
require 'nanoci/task'
require 'nanoci/tool_process'

class Nanoci
  class Tasks
    # Task to execute shell command
    class TaskShell < Task
      provides 'shell'

      # Initializes new instance of [TaskShell]
      # @param definition [TaskDefinition]
      # @param project [Project]
      def initialize(definition, project)
        definition = TaskShellDefinition.new(definition.params)
        super(definition, project)
      end

      def execute_imp(build, env)
        ToolProcess.run(@definition.cmd, chdir: env[CommonVars::WORKDIR], stdout: build.output, stderr: build.output)
      end
    end
  end
end
