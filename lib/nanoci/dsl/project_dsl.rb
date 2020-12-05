# frozen_string_literal: true

require 'nanoci/definition/project_definition'

module Nanoci
  module DSL
    # ProjectDSL class contains methods to support nano-ci project DSL
    class ProjectDSL
      # Gets or sets projet tag
      # @return [Symbol]
      attr_reader :tag

      # Gets or sets project name
      # @return [String]
      attr_reader :name

      # Gets a hash with plugins reqired by the project
      # @return [Hash<Symbol, String>]
      attr_reader :plugins

      # Initializes a new object of [ProjectDSL]
      # @param tag [Symbol] Tag of the project
      # @param name [String] Name of the project
      def initialize(tag, name)
        @tag = tag
        @name = name
        @plugins = {}
      end

      # Declares a requirement on a plugin
      # @param tag [Symbol] Plugin tag
      # @param version [String] Symver version string
      def plugin(tag, version)
        plugins[tag] = version
      end

      # Builds and returns [Nanoci::Definition::ProjectDefinition] from DSL
      def build
        hash = {
          name: name,
          tag: tag,
          plugins: plugins
        }
        Nanoci::Definition::ProjectDefinition.new(hash)
      end
    end
  end
end
