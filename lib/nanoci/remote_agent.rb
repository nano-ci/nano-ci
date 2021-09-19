# frozen_string_literal: true

require 'concurrent'

require 'nanoci/agent'
require 'nanoci/agent_status'

module Nanoci
  # Remote agent
  class RemoteAgent < Agent
    def initialize(tag, capabilities)
      super(tag, capabilities)

      reset_pending_job_future
    end

    # Sets a capabilities to a set reported by remote agent
    # @param value [Hash<Symbol>]
    def capabilities=(value)
      raise 'value should be a hash' unless value.is_a? Hash

      @capabilities = value
    end

    # Returns a future for a pending job scheduled to execute on the agent
    # @return [Concurrent::Promises::Future]
    def pending_job
      @pending_job_future
    end

    # Runs a job on remote agent
    # @param job [Nanoci::BuildJob]
    # @return [Concurrent::Promises::Promise::Future] A Future that contains a job
    def run_job(build, job)
      future = super

      @pending_job_future.fulfill job
      self.status = AgentStatus::PENDING
      future
    end

    def cancel_job
      super
      reset_pending_job_future
    end

    # Sets a new status of the agent
    # @param value [Nanoci::AgentStatus]
    def status=(value)
      # Reset next job future if agent becomes idle
      reset_pending_job_future if [AgentStatus::BUSY,
                                   AgentStatus::PENDING].include?(status) && value == AgentStatus::IDLE
      super
    end

    private

    def reset_pending_job_future
      # @type [Concurrent::Promises::Future]
      @pending_job_future = Concurrent::Promises.resolvable_future
    end
  end
end
