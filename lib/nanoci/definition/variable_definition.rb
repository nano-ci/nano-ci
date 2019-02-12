# frozen_string_literal: true

module Nanoci
  class Definition
    # Variable definition
    class VariableDefinition
      # Returns the tag of the variable
      # @return [Symbol]
      def tag
        @src[0]
      end

      # Returns the value of the variable
      # @return [String]
      def value
        @src[1] || ''
      end

      # Initializes a new instance of VariableDefiition
      # @param hash [Hash]
      def initialize(hash)
        @src = hash.to_a[0]
      end
    end
  end
end
