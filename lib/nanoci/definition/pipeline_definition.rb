# frozen_string_literal: true

require 'nanoci/definition/trigger_definition'
require 'nanoci/definition/stage_definition'

module Nanoci
  class Definition
    # Pipeline definition
    class PipelineDefinition
      attr_reader :hash

      def initialize(hash)
        # @type [Hash]
        @hash = hash
      end

      # Returns collection of triggers for the repo
      # @return [Array<TriggerDefinition>] collection of triggers for the repo
      def triggers
        read_triggers(@hash.fetch(:triggers, []))
      end

      # Returns the stages of the pipeline
      # @return [Array<StageDefinition>]
      def stages
        read_stages(@hash.fetch(:stages, []))
      end

      # Returns the links between stages
      # @return [Array<Array<Symbol>>]
      def links
        read_links(@hash.fetch(:links, []))
      end

      private

      # Reads trigger definitions from src
      # @param array [Array<Hash>]
      # @return [Array<TriggerDefitnion>]
      def read_triggers(array)
        array.map { |x| TriggerDefinition.new(x) }
      end

      # Reads stage definitions from array of hashes
      # @param array [Array<Hash>]
      # @return [Array<StageDefinition>]
      def read_stages(array)
        array.map { |s| StageDefinition.new(s) }
      end

      def read_links(array)
        array.map { |s| s.split('->').map(&:strip).map(&:to_sym) }
      end
    end
  end
end
