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

    # @return [Symbol]
    attr_reader :tag

    # @return [Symbol]
    attr_reader :type

    # Initializes new instance of [Trigger]
    # @param definition [Hash]
    def initialize(hash)
      @log = Logging.logger[self]
      @tag = hash[:tag]
      @type = hash[:type]
    end

    def run(build_scheduler, project)
      @build_scheduler = build_scheduler
      @project = project

      @log.info("running trigger #{tag}")
    end
  end
end
