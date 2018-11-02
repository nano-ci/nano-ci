# frozen_string_literal: true

require 'nanoci/definition/task_definition'
require 'nanoci/definition/variable_definition'

class Nanoci
  class Tasks
    # [TaskShell] definition
    class TaskShellDefinition < Nanoci::Definition::TaskDefinition

      # Prefix added to variable tag
      VARIABLE_PREFIX = 'task_shell'

      # Returns the command to execute
      # @return [String]
      attr_reader :cmd

      # Returns a set of environment variables
      # @return [Hash<Symbol, VariableDefinition>]
      attr_reader :env

      def initialize(hash)
        super(hash)

        @cmd = hash.fetch(:cmd, '')
        @env = hash.fetch(:env) { |src| (src || []).to_h.transform_keys(&:to_sym) }
      end
    end
  end
end
