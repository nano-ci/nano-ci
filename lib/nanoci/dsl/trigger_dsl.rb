# frozen_string_literal: true

module Nanoci
  module DSL
    # TriggerDSL class contains methods to support nano-ci trigger DSL.
    class TriggerDSL
      def initialize(component_factory, tag)
        @component_factory = component_factory
        @tag = tag
      end

      def type(type)
        @type = type
      end

      def schedule(schedule)
        @schedule = schedule
      end

      def build
        @component_factory.triggers.build(@tag, @type, @schedule)
      end
    end
  end
end
