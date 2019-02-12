# frozen_string_literal: true

require 'nanoci/definition/task_definition'

module Nanoci
  class Definition
    # Job definition
    class JobDefinition
      # Returns the tag of the job
      # @return [Symbol]
      def tag
        @hash.fetch(:tag).to_sym
      end

      # Returns an array of job's tasks
      # @return [Array<TaskDefinition>]
      def tasks
        read_tasks(@hash.fetch(:tasks, []))
      end

      # Initializes new instance of JobDefinition
      # @param hash [Hash]
      def initialize(hash)
        @hash = hash
      end

      private

      # Reads array of tasks from array of hashes
      # @param task_hash_array [Array<Hash>]
      # @return [Array<TaskDefinition>]
      def read_tasks(task_hash_array)
        task_hash_array.map { |d| TaskDefinition.new(d) }
      end
    end
  end
end
