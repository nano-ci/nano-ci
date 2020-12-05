# frozen_string_literal: true

require 'nanoci/definition/project_definition'
require 'nanoci/dsl/repo_dsl'

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

      # Gets a hash with repos
      # @return [Hash<Symbol, Nanoci::DSL::RepoDSL]
      attr_reader :repos

      # Initializes a new object of [ProjectDSL]
      # @param tag [Symbol] Tag of the project
      # @param name [String] Name of the project
      def initialize(tag, name)
        @tag = tag
        @name = name
        @plugins = {}
        @repos = []
      end

      # Declares a requirement on a plugin
      # @param tag [Symbol] Plugin tag
      # @param version [String] Symver version string
      def plugin(tag, version)
        plugins[tag] = version
      end

      # Declares a project's repo
      # @param tag [Symbol] Repo tag
      # @param block [Block] Repo DSL block
      def repo(tag, &block)
        raise "repo #{tag} is missing definition block" if block.nil?

        repo = RepoDSL.new(tag)
        repo.instance_eval(&block)
        @repos.push(repo)
      end

      # Builds and returns [Nanoci::Definition::ProjectDefinition] from DSL
      def build
        hash = {
          name: name,
          tag: tag,
          plugins: plugins,
          repos: repos.collect(&:build)
        }
        Nanoci::Definition::ProjectDefinition.new(hash)
      end
    end
  end
end
