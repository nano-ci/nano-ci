# frozen_string_literal: true

require 'nanoci/definition/task_definition'

module Nanoci
  class Plugins
    class RSpec
      # definition for [TaskTestRSpec]
      class TaskTestRSpecDefinition < Nanoci::Definition::TaskDefinition
        # @return [Symbol]
        attr_reader :action

        # @return [Hash]
        attr_reader :options

        # @return [String]
        attr_reader :result_file

        # initializes new instance of [TaskTestRSpecDefinition]
        def initialize(hash)
          super
          @action = hash.fetch(:action, :run_tool).to_sym
          @options = hash.fetch(:options, {})
          @result_file = hash.fetch(:result_file, nil)

          raise 'result_file must be specified if action is "read_file"' if \
              @action == :read_file && @result_file.nil?
        end
      end
    end
  end
end
