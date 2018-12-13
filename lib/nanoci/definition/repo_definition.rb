# frozen_string_literal: true

require 'nanoci/definition/trigger_definition'

module Nanoci
  class Definition
    # Repo definition
    class RepoDefinition

      # Returns the tag of the repo
      # @return [Symbol] the tag of the repo
      attr_reader :tag

      # Returns the type of the repo
      # @return [Symbol] the type of the repo
      attr_reader :type

      # Returns flag saying if this is main repo for a project
      # @return [Boolean] flag saying if this is main repo for a project
      attr_reader :main

      # Returns string with source location of the repo
      # @return [String]
      attr_reader :src

      # Returns string with name of the branch, tag, commit hash, etc - anything points to a commit
      # @return [String]
      attr_reader :branch

      # Returns collection of triggers for the repo
      # @return [Array<TriggerDefinition>] collection of triggers for the repo
      attr_reader :triggers

      # Returns authorization params for the repo
      # @return [Hash]
      attr_reader :auth

      # Returns type-specific paras of the repo
      # @return [Hash]
      attr_reader :params

      # Initializes new instance of RepoDefinition
      # @param hash [Hash]
      def initialize(hash)
        @tag = hash.fetch(:tag).to_sym
        @type = hash.fetch(:type).to_sym
        @main = hash.fetch(:main, false)
        @src = hash.fetch(:src)
        @auth = hash.fetch(:auth, nil)
        @params = hash
        @triggers = read_triggers(hash.fetch(:triggers, []))
      end

      # Reads trigger definitions from src
      # @param hash_array [Array<Hash>]
      # @return [Array<TriggerDefitnion>]
      def read_triggers(hash_array)
        hash_array.map { |x| read_trigger(x) }
      end

      # Reads trigger definition from src
      # @param hash [Hash]
      # @return [TriggerDefinition]
      def read_trigger(hash)
        TriggerDefinition.new(hash)
      end
    end
  end
end
