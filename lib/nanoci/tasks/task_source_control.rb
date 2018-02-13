require 'nanoci/task'

class Nanoci
  class Tasks
    class TaskSourceControl < Task
      attr_accessor :repo_tag
      attr_accessor :action
      attr_accessor :branch

      def initialize(hash = {})
        super(hash)
        @repo_tag = hash['repo']
        @action = hash['action']
        @branch = hash['branch']
      end

      def required_agent_capabilities(project)
        repo = project.repos[repo_tag]
        raise "Missing repo definition #{repo_tag}" if repo.nil?
        super(project) + repo.required_agent_capabilities
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

    Task.types['source-control'] = TaskSourceControl
  end
end
