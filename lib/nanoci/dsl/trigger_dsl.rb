# frozen_string_literal: true

module Nanoci
  module DSL
    # TriggerDSL class contains methods to support nano-ci trigger DSL.
    class TriggerDSL
      def initialize(tag)
        @tag = tag
      end

      def build
        raise 'method TriggerDSL#build should be implemented in subclasses'
      end
    end
  end
end
