# frozen_string_literal: true

require 'nanoci/mixins/logger'
require 'nanoci/mixins/provides'
require 'nanoci/system/event'

require_relative 'downstream_trigger_rule'

module Nanoci
  module Core
    # Base class for nano-ci triggers
    class Trigger
      extend Mixins::Provides
      include Mixins::Logger

      class << self
        def trigger_types
          @trigger_types ||= {}
        end

        def add_trigger_type(type, clazz)
          trigger_types[type] = clazz
        end

        def find_trigger_type(type)
          @trigger_types[type]
        end
      end

      def self.item_type
        'trigger'
      end

      # Storage specific id
      attr_reader :id

      # @return [Symbol]
      attr_reader :tag

      # @return [Nanoci::Core::Project]
      attr_accessor :project

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

      # Initializes new instance of [Trigger]
      # @param tag [Symbol] trigger tag
      # @param options [Hahs] optional args
      def initialize(tag:, options: {})
        @tag = tag
        @options = options || {}
        @start_time = nil
        @end_time = nil
        @previous_run_time = nil
        @next_run_time = nil
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

      # Called at time when Trigger is due.
      # Trigger is expected to update internal state and return [Hash] with outputs
      def pulse
        @previous_run_time = Time.now.utc
        { format_output(:trigger_time) => @previous_run_time.iso8601 }
      end

      def memento
        {
          id: id,
          tag: tag,
          project_tag: project.tag,
          options: @options,
          start_time: start_time,
          end_time: end_time,
          previous_run_time: previous_run_time,
          next_run_time: next_run_time
        }
      end

      def memento=(memento)
        raise ArgumentError 'tag mismatch' if tag != memento.fetch(:tag)

        @id = memento.fetch(:id)
        @start_time = memento.fetch(:start_time, nil)
        @end_time = memento.fetch(:end_time, nil)
        @previous_run_time = memento.fetch(:previous_run_time, nil)
        @next_run_time = memento.fetch(:next_run_time, nil)
      end

      protected

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
