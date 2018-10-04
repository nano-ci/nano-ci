# frozen_string_literal: true

require 'nanoci/definition/task_definition'

class Nanoci
  class Tasks
    class TaskShellDefinition < Nanoci::Definition::TaskDefinition
      # Returns the command to execute
      # @return [String]
      attr_reader :cmd

      def initialize(hash)
        super(hash)

        @cmd = hash.fetch(:cmd, '')
      end
    end
  end
end
