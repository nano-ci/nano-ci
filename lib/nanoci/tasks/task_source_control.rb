require 'nanoci/task'

class Nanoci
  class Tasks
    class TaskSourceControl < Task
      attr_accessor :repo_tag
      attr_accessor :action
      attr_accessor :workdir

      def initialize(hash = {})
        super(hash)
        @repo_tag = hash['repo']
        @action = hash['action']
        @workdir = hash['workdir']
      end

      def required_agent_capabilities(project)
        repo = project.repos[repo_tag]
        rase "Missing repo definition #{repo_tag}" if repo.nil?
        super(project) + repo.required_agent_capabilities
      end
    end

    Task.types['source-control'] = TaskSourceControl
  end
end
