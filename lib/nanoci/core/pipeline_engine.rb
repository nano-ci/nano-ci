# frozen_string_literal: true

require 'nanoci/mixins/logger'

module Nanoci
  module Core
    # PipelineEngine executes pipelines and propagates inputs/outputs
    class PipelineEngine
      include Nanoci::Mixins::Logger

      def initialize
        @pipelines = []
        @stages = {}
        # @type [Hash{Symbol => Array<Symbol>}]
        @pipes = Hash.new { |h, k| h[k] = [] }
      end

      # Runs the pipeline on the pipeline engine
      # @param pipeline [Nanoci::Core::Pipeline]
      def run_pipeline(pipeline)
        raise "duplicate pipeline #{pipeline.tag}" if duplicate? pipeline

        log.info "adding pipeline <#{pipeline.tag}> to pipeline engine"

        # TODO: process validation results
        pipeline.validate

        add_stages(pipeline)
        add_pipes(pipeline)

        pipelines.push(pipeline)

        start_pipeline(pipeline)

        log.info "pipeline <#{pipeline.tag}> is running"
      end

      private

      # Checks for duplicate pipeline
      # @param pipeline [Nanoci::Core::Pipeline]
      # @return Boolean true if there was another pipeline with the same tag; false otherwise
      def duplicate?(pipeline)
        @pipelines.any? { |x| x.tag == pipeline.tag }
      end

      # Starts the pipeline
      # @param pipeline [Nanoci::Pipeline]
      def start_pipeline(pipeline)
        # @param t [Nanoci::Trigger]
        pipeline.triggers.each { |t| t.run(self) }
      end

      def add_stages(pipeline)
        # @param s [Nanoci::Stage]
        pipeline.stages.each do |s|
          raise "duplicate stage #{s.tag}" if @stages.key? s.tag

          @stages[s.tag] = s
        end
      end

      def add_pipes(pipeline)
        # @param k [Symbol]
        # @param v [Array<Symbol>]
        pipeline.pipes.each do |(k, v)|
          @pipes[k].push(*v)
        end
      end
    end
  end
end
