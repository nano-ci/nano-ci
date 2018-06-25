# frozen_string_literal: true

require 'nanoci/definition/task_definition'

class Nanoci
  class Definition
    # Job definition
    class JobDefinition
      # Returns the tag of the job
      # @return [Symbol]
      attr_reader :tag

      # Returns an array of job's tasks
      # @return [Array<TaskDefinition>]
      attr_reader :tasks

      # Initializes new instance of JobDefinition
      # @param hash [Hash]
      def initialize(hash)
        @tag = hash.fetch :tag
        @tasks = read_tasks(hash.fetch(:tasks, []))
      end

      private

      # Reads array of tasks from array of hashes
      # @param task_hash_array [Array<Hash>]
      # @return [Array<TaskDefinition>]
      def read_tasks(task_hash_array)
        task_hash_array.select(&:read_task)
      end

      # Read task definition from hash
      # @param hash [Hash]
      # @return [TaskDefinition]
      def read_task(hash)
        TaskDefinition.new(hash)
      end
    end
  end
end
