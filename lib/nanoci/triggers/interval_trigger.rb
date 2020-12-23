# frozen_string_literal: true

require 'time'

require 'nanoci/trigger'

module Nanoci
  module Triggers
    # IntervalTriggers pulses a new output on defined interval.
    class IntervalTrigger < Trigger
      # Returns trigger interval in seconds
      # @return [Number]
      attr_reader :interval

      # Initializes new instance of IntervalTrigger
      # @param src [Hash]
      def initialze(src)
        super(src)
        @interval = src[:interval]
      end

      # Starts the trigger
      # @param pipeline_engine [Nanoci::PipelineEngine]
      def run(pipeline_engine)
        @timer = Concurrent::TimerTask.new(execution_interval: @interval) do
          outputs = {}
          outputs[format_output(:trigger_time)] = Time.now.utc.iso8601
          pipeline_engine.pulse(tag, outputs)
        end
        @timer.execute
      end
    end
  end
end
