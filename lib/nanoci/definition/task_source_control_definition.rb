# frozen_string_literal: true

require 'nanoci/definition/task_definition'

class Nanoci
  class Definition
    class TaskSourceControlDefinition < TaskDefinition
      attr_reader :repo
      attr_reader :branch
      attr_reader :action

      def initialize(hash)
        super(hash)
        @repo = hash.fetch(:repo).to_sym
        @branch = hash.fetch(:branch, nil)
        @action = hash.fetch(:action)
      end
    end
  end
end
