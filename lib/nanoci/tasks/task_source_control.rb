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
        @workdir = hash['workdir']
        @branch = hash['branch']
      end

      def required_agent_capabilities(project)
        repo = project.repos[repo_tag]
        raise "Missing repo definition #{repo_tag}" if repo.nil?
        super(project) + repo.required_agent_capabilities
      end

      def execute(build, agent)
        repo = build.project.repos[repo_tag]
        raise "Missing repo definition #{repo_tag}" if repo.nil?
        Dir.chdir(File.join(build.workdir(agent), workdir)) do
          case action
          when 'checkout'
            execute_checkout(repo, agent)
          end
        end
      end

      def execute_checkout(repo, agent)
        repo.clone(agent) unless repo.exists?(agent)
        repo.checkout(branch, agent)
      end
    end

    Task.types['source-control'] = TaskSourceControl
  end
end
