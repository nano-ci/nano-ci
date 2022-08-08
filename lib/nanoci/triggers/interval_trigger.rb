# frozen_string_literal: true

require 'logging'
require 'time'

require 'nanoci/core/trigger'

module Nanoci
  module Triggers
    # IntervalTriggers pulses a new output on defined interval.
    class IntervalTrigger < Core::Trigger
      provides :interval

      # Initializes new instance of IntervalTrigger
      # @param src [Hash]
      def initialize(tag:, interval:)
        super(tag: tag, type: type)
        @interval = interval
        @log = Logging.logger[self]
      end

      # Starts the trigger
      def run
        @timer = Concurrent::TimerTask.new(execution_interval: @interval) do
          @log.debug "interval trigger #{tag} signal pulse"
          pulse
        end
        @timer.execute
      end
    end
  end
end
