# frozen_string_literal: true

require 'nanoci/definition/task_definition'

module Nanoci
  class Plugins
    class RSpec
      # definition for [TaskTestRSpec]
      class TaskTestRSpecDefinition < Nanoci::Definition::TaskDefinition
        # @return [Symbol]
        def action
          @hash.fetch(:action, :run_tool).to_sym
        end

        # @return [Hash]
        def options
          @hash.fetch(:options, {})
        end

        # @return [String]
        def result_file
          @hash.fetch(:result_file, nil)
        end

        # initializes new instance of [TaskTestRSpecDefinition]
        def initialize(hash)
          super
          raise 'result_file must be specified if action is "read_file"' if \
              action == :read_file && result_file.nil?
        end
      end
    end
  end
end
