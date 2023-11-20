# frozen_string_literal: true

require_relative '../core/downstream_trigger_rule'
require_relative '../core/trigger'

module Nanoci
  module DSL
    # TriggerDSL class contains methods to support nano-ci trigger DSL.
    class TriggerDSL
      def initialize(tag)
        @tag = tag
        @options = {}
      end

      def downstream_trigger_rule(rule)
        raise "invalid downstream_trigger_rule value: #{rule}" unless Core::DownstreamTriggerRule.key?(rule)

        @options[:downstream_trigger_rule] = rule
      end

      def build
        clazz.new(tag: @tag, options: @options)
      end

      protected

      def clazz = Nanoci::Core::Trigger
    end
  end
end
