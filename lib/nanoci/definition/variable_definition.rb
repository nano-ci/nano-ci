# frozen_string_literal: true

class Nanoci
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
        @tag = hash.fetch(:tag).to_sym
        @value = hash.fetch(:value, '')
      end
    end
  end
end
