# frozen_string_literal: true

module Nanoci
  module Components
    # Runs triggers in the current thread
    class SingleThreadTriggerEngine
      def initialize
        @triggers = []
        # minimal cycle period
        # the engine does not pulse due triggers if less then @cycle_period passed
        @cycle_period = 1
      end

      # Adds a trigger to execute on the engine
      # @trigger [Nanoci::Core::Trigger]
      def add_trigger(trigger)
        @triggers.push trigger
      end

      def run(cancellation_token)
        until cancellation_token.cancellation_requested?
          cycle_start_ts = Time.now.utc
          @triggers.select(&:active).each do |x|
            x.raise_pulse if x.due?
          end
          cycle_end_ts = Time.now.utc
          cycle_elapsed = cycle_end_ts - cycle_start_ts
          cooldown_period = [0, @cycle_period - cycle_elapsed].max
          sleep cooldown_period
        end
      end
    end
  end
end
