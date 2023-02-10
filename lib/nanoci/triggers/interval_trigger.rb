# frozen_string_literal: true

require 'time'

require 'nanoci/core/trigger'
require 'nanoci/mixins/logger'

module Nanoci
  # Defines and registers built-in nano-ci triggers
  module Triggers
    # IntervalTriggers pulses a new output on defined interval.
    class IntervalTrigger < Core::Trigger
      include Mixins::Logger

      provides :interval

      attr_reader :interval

      def interval=(value)
        @interval = value
        @next_run_time = (@previous_run_time || Time.now.utc) + @interval
      end

      # Initializes new instance of IntervalTrigger
      # @param tag [Symbol] Trigger tag
      # @param project_tag [Symbol] Project tag
      # @param args [Hash] Optional args
      def initialize(tag:, project_tag:, options:)
        super(tag: tag, project_tag: project_tag, options: options)
        @interval = options[:interval]
        @previous_run_time = nil
        @next_run_time = Time.now.utc
      end

      def due?
        @next_run_time < Time.now.utc
      end

      def pulse
        outputs = super
        @next_run_time = Time.now.utc + @interval
        outputs
      end

      def memento
        m = super
        m[:interval] = @interval
        m[:type] = :interval
        m
      end

      def memento=(value)
        super(value)
        @interval = value[:interval]
      end
    end

    Nanoci::Core::Trigger.add_trigger_type(:interval, IntervalTrigger)
  end
end
