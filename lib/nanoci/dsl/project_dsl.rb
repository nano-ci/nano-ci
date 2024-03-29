# frozen_string_literal: true

require 'nanoci//core/project'

require_relative 'pipeline_dsl'
require_relative 'repo_dsl'

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

      attr_accessor :src

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

        repo = RepoDSL.new(@component_factory, tag)
        repo.instance_eval(&block)
        @repos.push(repo)
      end

      # Declares a project's pipeline
      # @param tag [Symbol] Pipeline tag
      # @param name [String] Pipeline name
      def pipeline(tag, name, &block)
        raise "pipeline #{name} is missing definition block" if block.nil?

        @pipeline = PipelineDSL.new(tag, name)

        Symbol.class_eval do
          def >>(other)
            (to_s << '>>' << other.to_s).to_sym
          end
        end

        @pipeline.instance_eval(&block)

        Symbol.remove_method(:>>)
      end

      # Builds and returns [Hash] from DSL
      # @return [Nanoci::Core::Project]
      def build
        project = Core::Project.new(
          name: name,
          tag: tag,
          pipeline: @pipeline&.build,
          repos: repos.collect(&:build),
          plugins: plugins
        )

        project.src = @src
        project
      end
    end
  end
end
