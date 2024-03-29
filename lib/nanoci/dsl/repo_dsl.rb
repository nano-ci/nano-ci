# frozen_string_literal: true

require 'nanoci/core/repo'

module Nanoci
  module DSL
    # Repo DSL
    class RepoDSL
      # Initializes a new instance of [Nanoci::DSL::RepoDSL]
      # @param tag [Symbol] Repo tag
      def initialize(component_factory, tag)
        @component_factory = component_factory
        @tag = tag
      end

      # Sets repo type
      # @param type [Symbol]
      def type(type)
        @type = type
      end

      # Sets repo URI
      # @param uri [String]
      def uri(uri)
        @uri = uri
      end

      # Sets repo auth parameters
      # @param hash [Hash]
      def auth(hash)
        @auth = hash
      end

      # Builds [Nanoci::Definition::RepoDefinition]
      def build
        Core::Repo.new(
          tag: @tag,
          type: @type,
          uri: @uri,
          auth: @auth
        )
      end
    end
  end
end
