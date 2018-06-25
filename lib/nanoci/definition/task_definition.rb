# frozen_string_literal: true

class Nanoci
  class Definition
    # Task definition
    class TaskDefinition
      # Returns the type of the task
      # @return [Symbol]
      attr_reader :type

      # Returns type-specific params of the task
      # @return [Hash]
      attr_reader :params

      # Initializes new instance of [TaskDefinition]
      # @param hash [Hash]
      def initialize(hash)
        @type = hash.fetch :type
        @params = hash
      end
    end
  end
end
