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

    def run(build_scheduler, env)
      @build_scheduler = build_scheduler
      @env = env
    end

    def trigger_build
      @log.info "checking repo #{@repo.tag} for new changes"
      begin
        unless @repo.detect_changes(@env)
          @log.info "repo #{@repo.tag} has no new changes"
          return
        end
      rescue StandardError => e
        @log.error "failed to check repo #{@repo.tag} for new changes"
        @log.error e
        return
      end

      @log.info "detected new changes in repo #{@repo.tag}, triggering a new build"
      @build_scheduler.trigger_build(@project, self)
    end
  end
end
