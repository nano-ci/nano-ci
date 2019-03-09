# frozen_string_literal: true

module Nanoci
  # List of event types
  module Events
    SCHEDULE_BUILDS = :schedule_builds
    FINALIZE_BUILDS = :finalize_builds
    CANCEL_PENDING_JOBS = :cancel_pending_jobs
  end
end
