# frozen_string_literal: true

require 'logging'

require 'nanoci/agent_status'

module Nanoci
  # Agent is an instance of nano-ci service that executes commands from
  # a main nano-ci service to run build jobs
  class Agent
    attr_reader :tag, :status, :status_timestamp

    # Agent capabilities
    # @return [Hash<Symbol, String>]
    attr_reader :capabilities

    # Build the agent currently working on
    # @return [Nanoci::Build]
    attr_reader :build

    # Gets a job agent is working on
    # @returns [Nanoci::BuildJob]
    attr_reader :current_job

    attr_accessor :workdir

    def initialize(tag, capabilities)
      @log = Logging.logger[self]
      @tag = tag

      raise 'capabilities should be a Hash' unless capabilities.is_a? Hash

      @capabilities = capabilities
      @current_job = nil
      self.status = AgentStatus::IDLE
    end

    def status=(value)
      @status = value
      @status_timestamp = Time.now.utc
    end

    def capability(name)
      @capabilities.key?(name) ? @capabilities[name] || true : nil
    end

    def capability?(required_capability)
      @capabilities.key?(required_capability)
    end

    def capabilities?(required_capabilities)
      raise 'required_capabilities should be a Set' \
        unless required_capabilities.is_a? Set

      Set.new(@capabilities.keys.to_set).superset? required_capabilities
    end

    # Runs a job on the agent
    # @param build [Nanoci::Build]
    # @param job [Nanoci::BuildJob]
    # @return [Concurrent::Promises::Future] An event triggered when job is done
    def run_job(build, job)
      @log.info "running job #{job.tag} on #{tag}"
      @current_job = job
      @build = build
      job.completed_future
    end

    def cancel_job
      @current_job = nil
      @build = nil
      self.status = AgentStatus::IDLE
      @log.info "canceled job #{job.tag} running on #{tag}"
    end
  end
end
