# frozen_string_literal: true

require 'nanoci/dsl/stage_dsl'
require 'nanoci/dsl/trigger_dsl'

module Nanoci
  module DSL
    # PipelineDSL class contains methods to support nano-ci pipeline DSL.
    class PipelineDSL
      def initialize(tag, name)
        @tag = tag
        @name = name
        @triggers = []
        @stages = []
        @pipes = []
      end

      def trigger(tag, &block)
        raise "trigger #{tag} is missing definition block" if block.nil?

        trigger_dsl = TriggerDSL.new(tag)
        trigger_dsl.instance_eval(&block)
        @triggers.push(trigger_dsl)
      end

      def stage(tag, **params, &block)
        raise "stage #{tag} is missing definition block" if block.nil?

        stage_dsl = StageDSL.new(tag, **params)
        stage_dsl.instance_eval(&block)
        @stages.push(stage_dsl)
      end

      def pipe(pipe)
        @pipes.push(pipe)
      end

      def build
        {
          tag: @tag,
          name: @name,
          triggers: @triggers.collect(&:build),
          stages: @stages.collect(&:build),
          pipes: @pipes
        }
      end
    end
  end
end
