# frozen_string_literal: true

require_relative '../core/downstream_trigger_rule'
require_relative '../core/stage'
require 'nanoci/dsl/job_dsl'

module Nanoci
  module DSL
    # StageDSL class contains methods to support nano-ci stage DSL.
    class StageDSL
      def initialize(component_factory, tag, inputs: [])
        @component_factory = component_factory
        @tag = tag
        @inputs = inputs
        @jobs = []
        @downstream_trigger_rule = Core::DownstreamTriggerRule.queue
        @hooks = {}
      end

      def downstream_trigger_rule(rule)
        raise "invalid downstream_trigger_rule value: #{rule}" unless Core::DownstreamTriggerRule.key?(rule)

        @downstream_trigger_rule = rule
      end

      def job(tag, **params, &block)
        raise "job #{tag} is missing definition block" if block.nil?

        job = JobDSL.new(@component_factory, tag, **params, &block)
        @jobs.push(job)
      end

      Core::Stage::STAGE_HOOKS.each do |hook|
        code = <<-CODE
          def #{hook}(&block)
            raise 'pipeline hook #{hook} is missing block' if block.nil?
            @hooks[:#{hook}] = block
          end
        CODE
        class_eval(code)
      end

      # Builds [Nanoci::Core::Stage] from the [Nanoci::DSL::StageDSL]
      # @param pipeline_hooks [Hash] pipeline level hooks applicable to a stage
      # @return [Nanoci::Core::Stage]
      def build(pipeline_hooks = {})
        Core::Stage.new(
          tag: @tag,
          inputs: @inputs,
          jobs: @jobs.collect(&:build),
          downstream_trigger_rule: @downstream_trigger_rule,
          hooks: pipeline_hooks.select { |k, _| Core::Stage::STAGE_HOOKS.include? k }.merge(@hooks)
        )
      end
    end
  end
end
