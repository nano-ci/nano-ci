# frozen_string_literal: true

require 'nanoci/common_vars'
require 'nanoci/definition/variable_definition'
require 'nanoci/task'
require 'nanoci/tasks/task_shell_definition'
require 'nanoci/tool_process'
require 'nanoci/variable'

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
        task_env_vars = variables.map { |x| [x.tag, x.expand(env)] }
                                 .to_h
                                 .transform_keys { |x| strip_var_prefix(x) }

        ToolProcess.run(@definition.cmd,
                        env: task_env_vars,
                        chdir: env[CommonVars::WORKDIR],
                        stdout: build.output,
                        stderr: build.output).wait
      end

      private

      def variables
        definition.env.map { |x| Variable.new(x) }
      end

      def strip_var_prefix(name)
        name.to_s.sub("#{TaskShellDefinition::VARIABLE_PREFIX}.", '')
      end
    end
  end
end
