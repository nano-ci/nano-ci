# frozen_string_literal: true

require 'yaml'

require 'nanoci/definition/repo_definition'
require 'nanoci/definition/stage_definition'
require 'nanoci/definition/variable_definition'

class Nanoci
  class Definition
    # Project Definition
    class ProjectDefinition
      # Returns the name of the project
      # @return [String] the name of the project
      attr_reader :name

      # Returns the tag of the project
      # @return [Symbol] the tag of the project
      attr_reader :tag

      # Returns the repos of the project
      # @return [Array<RepoDefinition>]
      attr_reader :repos

      # Returns the stages of the project
      # @return [Array<StageDefinition>]
      attr_reader :stages

      # Returns the variables of the project
      # @return [Array<VariableDefinition>]
      attr_reader :variables

      class << self
        # Reads project definition from string
        # @param src [String]
        # @return [ProjectDefinition]
        def read_string(src)
          hash = YAML.safe_load(src)
          ProjectDefinition.new(hash)
        end
      end

      # Initializes new instance of ProjectDefinition
      # @param hash [Hash{Symbol => String, Hash}]
      def initialize(hash)
        @name = hash[:name]
        @tag = hash[:tag]
        @repos = read_repos(hash[:repos] || [])
        @stages = read_stages(hash[:stages] || [])
        @variables = read_variables(hash[:variables] || [])
      end

      # Reads repo definitions from array of hashes
      # @param repo_hash_array [Array<Hash>]
      # @return [Array<RepoDefinition>]
      def read_repos(repo_hash_array)
        repo_hash_array.map(&method(:read_repo))
      end

      # Reads repo definition from hash
      # @param hash [Hash]
      # @return [RepoDefinition]
      def read_repo(hash)
        RepoDefinition.new(hash)
      end

      # Reads stage definitions from array of hashes
      # @param stage_hash_array [Array<Hash>]
      # @return [Array<StageDefinition>]
      def read_stages(stage_hash_array)
        stage_hash_array.map(&method(:read_stage))
      end

      # Reads stage definition from hash
      # @param hash [Hash]
      # @return [StageDefinition]
      def read_stage(hash)
        StageDefinition.new(hash)
      end

      # Reads variable definitions from array of hashes
      # @param variable_hash_array [Array<Hash>]
      # @return [Array<VariableDefinition>]
      def read_variables(variable_hash_array)
        variable_hash_array.map(&method(:read_variable))
      end

      # Reads variable from a hash
      # @param hash [Hash]
      # @return [VariableDefinition]
      def read_variable(hash)
        VariableDefinition.new(hash)
      end
    end
  end
end
