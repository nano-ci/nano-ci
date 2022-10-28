# frozen_string_literal: true

require_relative '../core/trigger_engine'

module Nanoci
  module Components
    # Runs triggers in the current thread
    class SingleThreadTriggerEngine < Nanoci::Core::TriggerEngine
      def initialize(trigger_repository, pipeline_engine)
        super(trigger_repository, pipeline_engine)
        # minimal cycle period
        # the engine does not pulse due triggers if less then @cycle_period passed
        @cycle_period = 1
      end

      def run(cancellation_token)
        until cancellation_token.cancellation_requested?
          cycle_start_ts = Time.now.utc
          run_cycle(cancellation_token)
          cycle_end_ts = Time.now.utc
          cycle_elapsed = cycle_end_ts - cycle_start_ts
          cooldown_period = [0, @cycle_period - cycle_elapsed].max
          sleep cooldown_period
        end
      end
    end
  end
end
