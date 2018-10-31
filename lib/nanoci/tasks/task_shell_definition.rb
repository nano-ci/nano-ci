# frozen_string_literal: true

require 'nanoci/definition/task_definition'
require 'nanoci/definition/variable_definition'

class Nanoci
  class Tasks
    # Definition for [TaskShell]
    class TaskShellDefinition < Nanoci::Definition::TaskDefinition

      # Prefix added to variable tag
      VARIABLE_PREFIX = "task_shell"

      # Returns the command to execute
      # @return [String]
      attr_reader :cmd

      # Returns a set of environment variables
      # @return [Hash<Symbol, VariableDefinition>]
      attr_reader :env

      def initialize(hash)
        super(hash)

        @cmd = hash.fetch(:cmd, '')
        @env = read_env(hash.fetch(:env, []))
      end

      private

      # Reads a set of env variables from source
      # @param env_vars [Array<Hash>]
      # @return [Hash<Symbol, VariableDefinition>]
      def read_env(env_vars)
        env_vars ||= []
        env_vars.map do |x|
          x = x.transform_keys { |k| "#{VARIABLE_PREFIX}.#{k}".to_sym }
          Nanoci::Definition::VariableDefinition.new(x)
        end
      end
    end
  end
end
