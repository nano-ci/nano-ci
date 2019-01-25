# frozen_string_literal: true

require 'nanoci/definition/task_definition'
require 'nanoci/definition/variable_definition'

module Nanoci
  class Tasks
    # [TaskShell] definition
    class TaskShellDefinition < Nanoci::Definition::TaskDefinition
      # Returns the command to execute
      # @return [String]
      def cmd
        @hash.fetch(:cmd, '')
      end

      # Returns a set of environment variables
      # @return [Hash<Symbol, VariableDefinition>]
      def env
        hash.fetch(:env) { |src| (src || []).to_h.transform_keys(&:to_sym) }
      end
    end
  end
end
