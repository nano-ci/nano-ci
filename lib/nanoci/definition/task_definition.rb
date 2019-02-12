# frozen_string_literal: true

module Nanoci
  class Definition
    # Task definition
    class TaskDefinition
      # Returns the type of the task
      # @return [Symbol]
      def type
        @hash.fetch(:type).to_sym
      end

      # Return the working dir for a task. Relative to build working dir
      # @return [String]
      def workdir
        @hash.fetch(:workdir, '.')
      end

      # Returns type-specific params of the task
      # @return [Hash]
      attr_reader :params

      # Initializes new instance of [TaskDefinition]
      # @param hash [Hash]
      def initialize(hash)
        @hash = hash
        @params = hash
      end
    end
  end
end
