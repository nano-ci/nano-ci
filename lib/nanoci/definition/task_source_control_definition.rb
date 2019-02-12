# frozen_string_literal: true

require 'nanoci/definition/task_definition'

module Nanoci
  class Definition
    class TaskSourceControlDefinition < TaskDefinition
      def repo
        @hash.fetch(:repo).to_sym
      end

      def branch
        @hash.fetch(:branch, nil)
      end

      def action
        @hash.fetch(:action)
      end
    end
  end
end
