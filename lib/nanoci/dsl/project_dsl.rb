# frozen_string_literal: true

require 'nanoci/definition/project_definition'

module Nanoci
  module DSL
    # ProjectDSL class contains methods to support nano-ci project DSL
    class ProjectDSL
      # Gets or sets projet tag
      # @return [Symbol]
      attr_accessor :tag

      # Gets or sets project name
      # @return [String]
      attr_accessor :name

      # Builds and returns [Nanoci::Definition::ProjectDefinition] from DSL
      def build
        hash = {
          name: name,
          tag: tag
        }
        Nanoci::Definition::ProjectDefinition.new(hash)
      end
    end
  end
end
