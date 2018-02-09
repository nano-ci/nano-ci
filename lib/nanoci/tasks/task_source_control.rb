require 'nanoci/task'

class Nanoci
  class Tasks
    class TaskSourceControl < Task
      attr_accessor :repo_tag
      attr_accessor :action
      attr_accessor :workdir
      attr_accessor :branch

      def initialize(hash = {})
        super(hash)
        @repo_tag = hash['repo']
        @action = hash['action']
        @workdir = hash['workdir'] || '.'
        @branch = hash['branch']
      end

      def required_agent_capabilities(project)
        repo = project.repos[repo_tag]
        raise "Missing repo definition #{repo_tag}" if repo.nil?
        super(project) + repo.required_agent_capabilities
      end

      def execute(build, env)
        repo = build.project.repos[repo_tag]
        raise "Missing repo definition #{repo_tag}" if repo.nil?
        task_workdir = File.join(build.workdir(env), workdir)
        FileUtils.mkdir_p(task_workdir) unless Dir.exist? task_workdir
        Dir.chdir(task_workdir) do
          case action
          when 'checkout'
            execute_checkout(repo, env, build.output)
          end
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
