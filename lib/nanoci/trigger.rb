# frozen_string_literal: true

require 'logging'

class Nanoci
  ##
  # Base class for nano-ci triggers
  class Trigger
    class << self
      def types
        @types ||= {}
      end
    end

    attr_reader :type

    def initialize(repo, hash = {})
      raise 'hash is not of type Hash' unless hash.is_a? Hash
      @log = Logging.logger[self]
      @repo = repo
      @type = hash[:type]
    end

    def run(build_scheduler, project, env)
      @build_scheduler = build_scheduler
      @project = project
      @env = env
    end

    def repo_has_changes?(repo, env)
      repo.changes?(env)
    rescue StandardError => e
      @log.error "failed to check repo #{repo.tag} for new changes"
      @log.error e
      false
    end

    def trigger_build
      @log.info "checking repo #{@repo.tag} for new changes"
      if repo_has_changes?(@repo, @env)
        @log.info "detected new changes in repo #{@repo.tag}" \
          ', triggering a new build'
        @build_scheduler.trigger_build(@project, self)
      else
        @log.info "repo #{@repo.tag} has no new changes"
      end
    end
  end
end
