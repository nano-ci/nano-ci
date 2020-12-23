# frozen_string_literal: true

module Nanoci
  class Stage
    module State
      IDLE = :idle
      RUNNING = :running

      VALUES = [IDLE, RUNNING].freeze
    end
  end
end
