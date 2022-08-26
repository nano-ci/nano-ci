# frozen_string_literal: true

require 'nanoci/dsl/trigger_dsl'
require 'nanoci/triggers/interval_trigger'

module Nanoci
  # Defines and registers IntervalTriggerDSL
  module Triggers
    # Extends TriggerDSL to support properties for IntervalTrigger
    class IntervalTriggerDSL < Nanoci::DSL::TriggerDSL
      def interval(value)
        @interval = value
      end

      def build
        IntervalTrigger.new(tag: @tag, interval: @interval)
      end
    end

    Nanoci::DSL::PipelineDSL.add_dsl_type(:interval, Nanoci::Triggers::IntervalTriggerDSL)
  end
end