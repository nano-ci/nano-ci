# frozen_string_literal: true

require 'nanoci/definition/trigger_definition'

class Nanoci
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

      # Returns collection of triggers for the repo
      # @return [Array<TriggerDefinition>] collection of triggers for the repo
      attr_reader :triggers

      # Returns type-specific paras of the repo
      # @return [Hash]
      attr_reader :params

      # Initializes new instance of RepoDefinition
      # @param hash [Hash]
      def initialize(hash)
        @tag = hash.fetch(:tag)
        @type = hash.fetch(:type)
        @main = hash.fetch(:main, false)
        @src = hash.fetch(:src)
        @params = hash
        @triggers = read_triggers(hash[:triggers] || [])
      end

      # Reads trigger definitions from src
      # @param hash_array [Array<Hash>]
      # @return [Array<TriggerDefitnion>]
      def read_triggers(hash_array)
        hash_array.select(&:read_trigger)
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
