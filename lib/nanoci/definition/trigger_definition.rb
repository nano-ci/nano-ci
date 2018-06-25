# frozen_string_literal: true

class Nanoci
  class Definition
    # Trigger definition
    class TriggerDefinition
      # Type of the trigger
      # @return [Symbol]
      attr_reader :type

      # Type-specific params of the trigger
      # @return [Hash]
      attr_reader :params

      # Initializes new instance of [TriggerDefinition]
      # @param hash [Hash]
      def initialize(hash)
        @type = hash.fetch(:type)
        @params = hash
      end
    end
  end
end
