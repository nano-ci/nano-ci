# frozen_string_literal: true

module Nanoci
  module Core
    class Job
      module State
        # Pending is the initial state of a job meaning job is pending the very first execution
        PENDING = :pending
        # Job is triggered and scheduled for excecution
        SCHEDULED = :scheduled
        # Job is running
        RUNNING = :running
        # Last job run was successful
        SUCCESSFUL = :successful
        # Last job run failed
        FAILED = :failed

        VALUES = [PENDING, SCHEDULED, RUNNING, SUCCESSFUL, FAILED].freeze
        ACTIVE = [SCHEDULED, RUNNING].freeze
      end
    end
  end
end
