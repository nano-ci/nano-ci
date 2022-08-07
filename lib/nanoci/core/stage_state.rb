# frozen_string_literal: true

module Nanoci
  module Core
    class Stage
      module State
        IDLE = :idle
        RUNNING = :running

        VALUES = [IDLE, RUNNING].freeze
      end
    end
  end
end
