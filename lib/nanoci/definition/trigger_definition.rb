# frozen_string_literal: true

module Nanoci
  class Definition
    # Trigger definition
    class TriggerDefinition
      # Type of the trigger
      # @return [Symbol]
      def type
        @hash.fetch(:type)
      end

      # Type-specific params of the trigger
      # @return [Hash]
      def params
        @hash
      end

      # Initializes new instance of [TriggerDefinition]
      # @param hash [Hash]
      def initialize(hash)
        @hash = hash
      end
    end
  end
end
