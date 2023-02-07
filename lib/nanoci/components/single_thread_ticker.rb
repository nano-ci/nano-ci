# frozen_string_literal: true

module Nanoci
  module Components
    # A ticker that ticks all tickables in a single thread
    class SingleThreadTicker
      def initialize
        @tickables = []
        @tick_period = 1
      end

      def add_tickable(*tkbls)
        tkbls.each do |tkbl|
          @tickables.push(tkbl)
        end
      end

      def run(cancellation_token)
        until cancellation_token.cancellation_requested?
          cycle_start_ts = Time.now.utc
          tick(cancellation_token)
          cycle_end_ts = Time.now.utc
          cycle_elapsed = cycle_end_ts - cycle_start_ts
          cooldown_period = [0, @tick_period - cycle_elapsed].max
          sleep cooldown_period unless cooldown_period.zero?
        end
      end

      def tick(cancellation_token)
        @tickables.each do |t|
          t.tick(cancellation_token) unless cancellation_token.cancellation_requested?
        end
      end
    end
  end
end
