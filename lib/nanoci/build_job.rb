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

    # Gets job state
    # @return [Nanoci::Build::State]
    attr_reader :state

    # Geta time when job was put to execution queue
    # @return [Time]
    attr_reader :queue_time

    # Gets time when job was scheduled for execion on an agent
    # @return [Time]
    attr_reader :schedule_time

    # Gets time when job was started on an agent
    # @return [Time]
    attr_reader :start_time

    # Gets time when job was completed on an agent
    # @return [Time]
    attr_reader :complete_time

    # Gets an future with the job triggered then job is completed
    # @return [Concurrent::Promises::Future]
    attr_reader :completed_future

    def state=(value)
      logger.debug("build job #{build.tag}.#{definition.tag} state changed from #{Build::State.key(@state)} to #{Build::State.key(value)}")
      @state = value
      update_state_time(@state)
      # rubocop:disable Style/CaseEquality
      # Range#=== returns true if value is in range, Rubocop is wrong here
      @completed_future.resolve(self) if Build::State.done === @state
      # rubocop:enable Style/CaseEquality
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
      @completed_future = Concurrent::Promises.resolvable_future
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

    private

    # Updates job timestamps when state is changed
    # @param state [Nanoci::Build::State]
    def update_state_time(state)
      case state
      when Build::State::QUEUED
        @queue_time = Time.now.utc
      when Build::State::PENDING
        @schedule_time = Time.now.utc
      when Build::State::RUNNING
        @start_time = Time.now.utc
      when Build::State.done
        @complete_time = Time.now.utc
      end
    end
  end
end
