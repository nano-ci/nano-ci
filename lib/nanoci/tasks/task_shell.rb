# frozen_string_literal: true

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

      # Executes [TaskShell]
      # @param build [Nanoci::Build]
      # @param workdir [String]
      def execute_imp(build, workdir)
        ToolProcess.run(@definition.cmd,
                        env: definition.env,
                        vars: build.variables,
                        chdir: workdir,
                        stdout: build.output,
                        stderr: build.output).wait
      end
    end
  end
end
