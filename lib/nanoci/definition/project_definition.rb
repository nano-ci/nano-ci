# frozen_string_literal: true

require 'yaml'

require 'nanoci/definition/repo_definition'
require 'nanoci/definition/stage_definition'
require 'nanoci/definition/variable_definition'

module Nanoci
  class Definition
    # Project Definition
    class ProjectDefinition
      # Returns the name of the project
      # @return [String] the name of the project
      def name
        @hash.fetch(:name)
      end

      # Returns the tag of the project
      # @return [Symbol] the tag of the project
      def tag
        @hash.fetch(:tag)
      end

      # Returns the repos of the project
      # @return [Array<RepoDefinition>]
      def repos
        read_repos(@hash.fetch(:repos, []))
      end

      # Returns the variables of the project
      # @return [Array<VariableDefinition>]
      def variables
        read_variables(@hash.fetch(:variables, []))
      end

      # Initializes new instance of ProjectDefinition
      # @param hash [Hash{Symbol => String, Hash}]
      def initialize(hash)
        @hash = hash
      end

      # Reads repo definitions from array of hashes
      # @param repo_hash_array [Array<Hash>]
      # @return [Array<RepoDefinition>]
      def read_repos(repo_hash_array)
        repo_hash_array.map { |s| RepoDefinition.new(s) }
      end

      # Reads variable definitions from array of hashes
      # @param variable_hash_array [Array<Hash>]
      # @return [Array<VariableDefinition>]
      def read_variables(variable_hash_array)
        variable_hash_array.map { |s| VariableDefinition.new(s) }
      end

      def to_yaml
        @hash.to_yaml
      end
    end
  end
end
