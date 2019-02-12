# frozen_string_literal: true

require 'logging'

require 'nanoci/build'

module Nanoci
  ##
  # BuildJob is the class to track execution of a Job on agent
  class BuildJob
    include Logging.globally

    # A build the job belongs to
    # @return [Nanoci::Build]
    attr_reader :build

    # A job that definex this build
    # @return [Nanoci::Job]
    attr_reader :definition

    attr_reader :state

    def state=(value)
      logger.debug("build job #{build.tag}.#{definition.tag} state changed from #{Build::State.key(@state)} to #{Build::State.key(value)}")
      @state = value
    end

    def tag
      definition.tag
    end

    # Initializes new instance of [BuildJob]
    # @param build [Nanoci::Build]
    # @param definition [Nanoci::Job]
    def initialize(build, definition)
      @build = build
      @definition = definition
      @state = Build::State::UNKNOWN
    end

    def required_agent_capabilities
      definition.required_agent_capabilities(build)
    end

    def memento
      {
        tag: tag,
        state: Build::State.key(state)
      }
    end
  end
end
