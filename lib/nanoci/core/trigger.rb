# frozen_string_literal: true

require 'logging'

require 'nanoci/mixins/logger'
require 'nanoci/mixins/provides'

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

      # @return [Symbol]
      attr_reader :type

      # Trigger schedule
      attr_reader :schedule

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

      # Initializes new instance of [Trigger]
      # @param definition [Hash]
      def initialize(tag:, type:, schedule:)
        @tag = tag
        @type = type
        @schedule = schedule
        @start_time = nil
        @end_time = nil
        @previous_run_time = nil
        @next_run_time = nil
        @observers = []
      end

      def add_observer(observer)
        @observers.push(observer)
      end

      # Starts the trigger
      # @param stage_complete_publisher [Nanoci::Core::StageCompletePublisher]
      def run
        log.info("running trigger #{tag}")
      end

      protected

      def pulse
        outputs = {}
        outputs[format_output(:trigger_time)] = Time.now.utc.iso8601
        @observers.each do |o|
          o.pulse(format_tag(tag), outputs)
        end
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
