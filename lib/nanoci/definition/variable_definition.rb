# frozen_string_literal: true

module Nanoci
  class Definition
    # Variable definition
    class VariableDefinition
      # Returns the tag of the variable
      # @return [Symbol]
      attr_reader :tag

      # Returns the value of the variable
      # @return [String]
      attr_reader :value

      # Initializes a new instance of VariableDefiition
      # @param hash [Hash]
      def initialize(hash)
        src = hash.to_a[0]
        @tag = src[0]
        @value = src[1] || ''
      end
    end
  end
end
