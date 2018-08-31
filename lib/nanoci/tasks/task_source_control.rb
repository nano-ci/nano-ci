# frozen_string_literal: true

require 'nanoci/definition/task_source_control_definition'
require 'nanoci/task'

class Nanoci
  # Build-in nano-ci tasks
  class Tasks
    # Task to work with SCM tools
    class TaskSourceControl < Task
      provides 'source-control'

      attr_accessor :repo_tag
      attr_accessor :repo
      attr_accessor :action
      attr_accessor :branch

      # Initializes new instance of [TaskSourceControl]
      # @param definition [TaskDefinition]
      # @param project [Project]
      def initialize(definition, project)
        definition = Nanoci::Definition::TaskSourceControlDefinition.new(definition.params)
        super(definition, project)
        @repo_tag = definition.repo
        @repo = project.repos[repo_tag]
        raise "Missing repo definition #{repo_tag}" if repo.nil?
        @action = definition.action
        @branch = definition.branch
      end

      def required_agent_capabilities
        super + repo.required_agent_capabilities
      end

      def execute_imp(build, env)
        repo = build.project.repos[repo_tag]
        raise "Missing repo definition #{repo_tag}" if repo.nil?
        case action
        when 'checkout'
          execute_checkout(repo, env, build.output)
        end
      end

      def execute_checkout(repo, env, output)
        repo.update(env)
        changeset = branch || repo.current_commit
        repo.checkout(changeset, env, stdout: output, stderr: output)
      end
    end
  end
end
