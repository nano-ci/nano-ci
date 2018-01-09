class Nanoci
  class BuildJob
    attr_accessor :job
    attr_accessor :state

    def initialize(job)
      @job = job
    end

    def required_agent_capabilities(project)
      job.tasks.flat_map { |t| t.required_agent_capabilities(project) }
    end
  end
end
