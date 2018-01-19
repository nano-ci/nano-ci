require 'logging'

class Nanoci
  class Trigger
    @types = {}

    def self.types
      @types
    end

    attr_accessor :type

    def initialize(repo, project, hash = {})
      @log = Logging.logger[self]
      @repo = repo
      @project = project
      @type = hash['type']
    end

    def run(build_scheduler)
      @build_scheduler = build_scheduler
    end

    def trigger_build
      if @repo.detect_changes
        @log.info "detected new changes in repo #{@repo.tag}, triggering a new build"
        @build_scheduler.trigger_build(@project, self)
      end
    end
  end
end
