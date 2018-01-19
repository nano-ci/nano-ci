class Nanoci
  class Trigger
    @types = {}

    def self.types
      @types
    end

    attr_accessor :type

    def initialize(repo, project, hash = {})
      @repo = repo
      @project = project
      @type = hash['type']
    end

    def run(build_scheduler)
      @build_scheduler = build_scheduler
    end

    def trigger_build
      @build_scheduler.trigger_build(@project, self) if @repo.detect_changes
    end
  end
end
