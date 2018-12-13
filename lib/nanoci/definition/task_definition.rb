# frozen_string_literal: true

module Nanoci
  class Definition
    # Task definition
    class TaskDefinition
      # Returns the type of the task
      # @return [Symbol]
      attr_reader :type

      # Return the working dir for a task. Relative to project working dir
      # @return [String]
      attr_reader :workdir

      # Returns type-specific params of the task
      # @return [Hash]
      attr_reader :params

      # Initializes new instance of [TaskDefinition]
      # @param hash [Hash]
      def initialize(hash)
        @type = hash.fetch(:type).to_sym
        @workdir = hash.fetch(:workdir, '.')
        @params = hash
      end
    end
  end
end
