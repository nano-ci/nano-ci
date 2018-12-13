# frozen_string_literal: true

require 'nanoci/common_vars'
require 'nanoci/task'
require 'nanoci/tasks/task_shell_definition'
require 'nanoci/tool_process'

module Nanoci
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
        ToolProcess.run(@definition.cmd,
                        env: definition.env,
                        vars: env,
                        chdir: env[CommonVars::WORKDIR],
                        stdout: build.output,
                        stderr: build.output).wait
      end
    end
  end
end
