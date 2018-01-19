require 'nanoci/project'
require 'nanoci/task'

class Nanoci
  ##
  # A job is a collection of tasks to run actions and produce artifacts
  class Job
    attr_accessor :project
    attr_accessor :tag
    attr_accessor :tasks
    attr_accessor :artifacts

    def initialize(project, hash = {})
      @project = project
      @tag = hash['tag']
      @tasks = []
      @artifacts = []
    end

    def required_agent_capabilities
      @tasks.map { |x| x.required_agent_capabilities(@project) }.reduce(:merge)
    end
  end
end
