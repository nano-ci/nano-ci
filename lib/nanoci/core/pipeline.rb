# frozen_string_literal: true

require 'nanoci/core/stage'
require 'nanoci/core/trigger'
require 'nanoci/mixins/logger'

module Nanoci
  module Core
    # Pipeline is the  class that organizes data flow between project stages.
    # rubocop:disable Metrics:ClassLength
    class Pipeline
      include Mixins::Logger

      # Gets the pipeline tag.
      # @return [Symbol]
      attr_reader :tag

      # Gets the pipeline name.
      # @return [String]
      attr_reader :name

      # @return [Array<Trigger>]
      attr_reader :triggers

      # @return [Array<Stage>]
      attr_reader :stages

      # @return [Hash{Symbol => Array<Symbol>}]
      attr_reader :pipes

      # Hash of pipeline hooks
      # @return [Hash{Symbol => Proc}]
      attr_reader :hooks

      def events
        @stages.map(&:events).flat_map { |x| x } + @events
      end

      # Initializes new instance of Pipeline
      # @param tag [Symbol] Pipeline tag
      # @param name [String] Pipeline name
      # @param triggers [Array<Trigger>] Array of pipeline triggers
      # @param stages [Array<Stage>] Array of pipeline stages
      # @param pipes [Hash{Symbol -> Array<Symbol>}] Hash of pipeline pipes
      # @param hooks [Hash{Symbol -> Proc}] Hash of pipeline hooks
      def initialize(tag:, name:, triggers:, stages:, pipes:, hooks:) # rubocop:disable Metrics/ParameterLists All 6 arguments are required to set initial object state
        @tag = tag
        @name = name
        @triggers = triggers
        @stages = stages
        @pipes = pipes
        @hooks = hooks
        @events = []

        validate
      end

      # Validates the pipeline. Raises ArgumentError if there pipeline is invalid
      def validate
        raise ArgumentError, 'tag is nil' if tag.nil?
        raise ArgumentError, 'tag is not a Symbol' unless tag.is_a? Symbol

        raise ArgumentError, 'name is nil' if name.nil?
        raise ArgumentError, 'name is not a String' unless name.is_a? String

        validate_triggers
        validate_stages
        validate_pipes
        validate_hooks
      end

      def find_stage(tag)
        stages.select { |s| s.tag == tag }.first
      end

      def find_trigger(tag)
        triggers.select { |t| t.full_tag == tag }.first
      end

      def job_complete(stage_tag, job_tag, outputs)
        stage = find_stage(stage_tag)
        stage.job_complete(job_tag, outputs)
        on_stage_complete(stage) if stage.success?
      end

      def trigger_fired(trigger_tag, outputs)
        trigger = find_trigger(trigger_tag)
        trigger_downstream(trigger.full_tag, outputs)
      end

      def on_stage_complete(stage)
        trigger_downstream(stage.tag, stage.outputs)
      end

      def memento
        {
          stages: @stages.to_h { |s| [s.tag, s.memento] }
        }
      end

      def memento=(value)
        value.fetch(:stages, {}).each do |tag, stage_memento|
          stage = find_stage(tag.to_sym)
          stage.memento = stage_memento unless stage.nil?
        end
      end

      private

      def trigger_downstream(upstream_stage_tag, outputs)
        pipes.fetch(upstream_stage_tag, []).each do |next_stage_tag|
          next_stage = find_stage(next_stage_tag)
          next_stage.trigger(outputs)
        end
      end

      def validate_triggers
        raise ArgumentError, 'triggers is nil' if triggers.nil?
        raise ArgumentError, 'triggers is not an Array' unless triggers.is_a? Array

        triggers.each do |t|
          unless pipes.key?(t.full_tag)
            log.warn("trigger #{t.tag} output is not connected to any of stage inputs")
            return false
          end
        end
        true
      end

      def validate_stages
        raise ArgumentError, 'stages is nil' if stages.nil?
        raise ArgumentError, 'stages is not an Array' unless stages.is_a? Array

        set = Set.new
        stages.each do |s|
          raise ArgumentError, "duplicate state #{s.tag}" if set.include? s.tag

          set.add(s.tag)
        end
      end

      def validate_pipes
        raise ArgumentError, 'pipes is nil' if pipes.nil?
        raise ArgumentError, 'pipes is not a Hash' unless pipes.is_a? Hash

        validate_pipe_connections
      end

      def validate_pipe_connections
        pipes.each_pair do |key, value|
          validate_pipe_pair key, value
        end
      end

      def validate_pipe_pair(key, value)
        raise ArgumentError, "stage #{key} does not exist" if find_stage(key).nil? && find_trigger(key).nil?

        raise ArgumentError, "pipe #{key} connection array is nil" if value.nil?
        raise ArgumentError, "pipe #{key} connections object is not an Array" unless value.is_a? Array

        value.each do |ps|
          raise ArgumentError, "stage #{ps} does not exist" if find_stage(ps).nil?
        end
      end

      def validate_hooks
        raise ArgumentError, 'hooks is nil' if hooks.nil?
      end
    end
  end
end
