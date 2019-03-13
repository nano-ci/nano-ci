# frozen_string_literal: true

require 'logging'

require 'nanoci/mixins/provides'

module Nanoci
  ##
  # Base class for nano-ci triggers
  class Trigger
    extend Mixins::Provides

    def self.item_type
      'trigger'
    end

    attr_reader :type
    attr_reader :repo

    # Initializes new instance of [Trigger]
    # @param repo [Repository]
    # @param definition [TriggerDefinition]
    def initialize(repo, definition)
      @log = Logging.logger[self]
      @repo = repo
      @type = definition.type
    end

    def run(build_scheduler, project)
      @build_scheduler = build_scheduler
      @project = project

      @log.info("running trigger #{repo.tag}.#{type}")
    end

    def repo_has_changes?(repo)
      repo.changes?
    rescue StandardError => e
      @log.error "failed to check repo #{repo.tag} for new changes"
      @log.error e
      false
    end

    def trigger_build
      @log.info "checking repo #{@repo.tag} for new changes"
      if repo_has_changes?(@repo)
        @log.info "detected new changes in repo #{@repo.tag}" \
          ', triggering a new build'
        @build_scheduler.trigger_build(@project, self)
      else
        @log.info "repo #{@repo.tag} has no new changes"
      end
    end
  end
end
