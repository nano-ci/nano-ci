# frozen_string_literal: true

module Nanoci
  class Job
    module State
      IDLE = :idle
      RUNNING = :running

      VALUES = [IDLE, RUNNING].freeze
    end
  end
end
