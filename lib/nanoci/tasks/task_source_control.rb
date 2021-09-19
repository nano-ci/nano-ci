# frozen_string_literal: true

require 'nanoci/definition/task_source_control_definition'
require 'nanoci/task'

module Nanoci
  # Build-in nano-ci tasks
  class Tasks
    # Task to work with SCM tools
    class TaskSourceControl < Task
      provides 'source-control'

      attr_accessor :repo_tag, :repo, :action, :branch

      # Initializes new instance of [TaskSourceControl]
      # @param definition [TaskDefinition]
      def initialize(definition)
        definition = Nanoci::Definition::TaskSourceControlDefinition.new(definition.params)
        super
        @repo_tag = definition.repo
        @action = definition.action
        @branch = definition.branch
      end

      def required_agent_capabilities(build)
        repo = build.project.repos[repo_tag]
        super(build) + repo.required_agent_capabilities
      end

      def execute_imp(build, workdir)
        repo = build.project.repos[repo_tag]
        raise "Missing repo definition #{repo_tag}" if repo.nil?

        case action
        when 'checkout'
          execute_checkout(repo, workdir, build.output)
        end
      end

      private

      def execute_checkout(repo, workdir, output)
        repo.update(workdir)
        changeset = branch || repo.current_commit
        repo.checkout(workdir, changeset, stdout: output, stderr: output)
      end
    end
  end
end
