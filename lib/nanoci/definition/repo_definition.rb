# frozen_string_literal: true

require 'nanoci/definition/trigger_definition'

module Nanoci
  class Definition
    # Repo definition
    class RepoDefinition
      # Returns the tag of the repo
      # @return [Symbol] the tag of the repo
      def tag
        @hash.fetch(:tag).to_sym
      end

      # Returns the type of the repo
      # @return [Symbol] the type of the repo
      def type
        @hash.fetch(:type).to_sym
      end

      # Returns flag saying if this is main repo for a project
      # @return [Boolean] flag saying if this is main repo for a project
      def main
        @hash.fetch(:main, false)
      end

      # Returns string with source location of the repo
      # @return [String]
      def src
        @hash.fetch(:src)
      end

      # Returns string with name of the branch, tag, commit hash, etc - anything points to a commit
      # @return [String]
      def branch
        @hash.fetch(:branch, nil)
      end

      # Returns authorization params for the repo
      # @return [Hash]
      def auth
        @hash.fetch(:auth, nil)
      end

      # Returns type-specific paras of the repo
      # @return [Hash]
      def params
        @hash
      end

      # Initializes new instance of RepoDefinition
      # @param hash [Hash]
      def initialize(hash)
        @hash = hash
      end
    end
  end
end
