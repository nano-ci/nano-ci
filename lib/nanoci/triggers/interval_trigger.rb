# frozen_string_literal: true

require 'time'

require 'nanoci/core/trigger'
require 'nanoci/mixins/logger'

module Nanoci
  module Triggers
    # IntervalTriggers pulses a new output on defined interval.
    class IntervalTrigger < Core::Trigger
      include Mixins::Logger

      provides :interval

      # Initializes new instance of IntervalTrigger
      # @param src [Hash]
      def initialize(tag:, interval:)
        super(tag: tag)
        @interval = interval
        @next_run_time = Time.now.utc + @interval
      end

      def due?
        @next_run_time < Time.now.utc
      end

      protected

      def on_pulse
        super
      ensure
        @next_run_time = Time.now.utc + @interval
      end
    end
  end
end
