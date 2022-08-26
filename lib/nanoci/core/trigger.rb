# frozen_string_literal: true

require 'logging'

require 'nanoci/core/trigger_pulse_event_args'
require 'nanoci/mixins/logger'
require 'nanoci/mixins/provides'
require 'nanoci/system/event'

module Nanoci
  module Core
    # Base class for nano-ci triggers
    class Trigger
      extend Mixins::Provides
      include Mixins::Logger

      def self.item_type
        'trigger'
      end

      # @return [Symbol]
      attr_reader :tag

      # Gets the fully formatted tag for pipeline pipes
      # @return [Symbol]
      def full_tag
        format_tag(tag)
      end

      # Get state of the trigger
      # @return [Boolean] True if trigger is active; false otherwise
      attr_reader :active

      # Date and time when this trigger becomes active
      # @return [Time]
      attr_reader :start_time

      # Date and time when this triggers disables
      # @return [Time]
      attr_reader :end_time

      # Date and time of previous trigger execution
      # @return [Time]
      attr_reader :previous_run_time

      # Date and time of the next trigger execution
      # @return [Time]
      attr_reader :next_run_time

      # Occurs when it's time to trigger pipeline line (on schedule, time elapsed, external event)
      # @returns [Nanoci::System::Event]
      attr_reader :pulse

      # Initializes new instance of [Trigger]
      # @param definition [Hash]
      def initialize(tag:)
        @tag = tag
        @start_time = nil
        @end_time = nil
        @previous_run_time = nil
        @next_run_time = nil
        @pulse = System::Event.new
      end

      # Starts the trigger
      # @param stage_complete_publisher [Nanoci::Core::StageCompletePublisher]
      def run
        log.info("running trigger #{tag}")
        @active = true
      end

      def stop
        @active = false
        log.info("trigger #{tag} is stopped")
      end

      # is trigger due to run?
      # @return [Boolean]
      def due?
        false
      end

      # Raises #pulse event
      def raise_pulse
        on_pulse
      end

      protected

      def on_pulse
        @previous_run_time = Time.now.utc
        outputs = { format_output(:trigger_time) => @previous_run_time.iso8601 }

        @pulse.invoke(self, TriggerPulseEventArgs.new(self, outputs))
      end

      def format_tag(tag)
        "trigger.#{tag}".to_sym
      end

      # Formats output tag by adding trigger prefix
      # @param output_tag [Symbol]
      # @return [Symbol]
      def format_output(output_tag)
        "#{format_tag(tag)}.#{output_tag}".to_sym
      end
    end
  end
end
