# frozen_string_literal: true

require 'logging'

require 'nanoci'
require 'nanoci/core/pipeline'
require 'nanoci/core/repo'

module Nanoci
  module Core
    # Represents a project in nano-ci
    class Project
      attr_reader :name, :tag, :plugins

      # @return [Array<Repo>]
      attr_reader :repos

      # @return [Nanoci::Pipeline]
      attr_reader :pipeline

      # Initializes new instance of [Project]
      # @param source [Hash] Hash with data from DSL
      def initialize(name:, tag:, pipeline:, repos: [], plugins: {})
        @log = Logging.logger[self]
        @name = name
        @tag = tag
        @repos = repos
        @pipeline = pipeline
        @plugins = plugins

        validate
      end

      def validate
        validate_tag
        validate_name
        validate_pipeline
        validate_repos
        validate_plugins
      end

      private

      def validate_tag
        raise ArgumentError, 'tag is nil' if tag.nil?
        raise ArgumentError, 'tag is not a Symbol' unless tag.is_a? Symbol
      end

      def validate_name
        raise ArgumentError, 'name is nil' if name.nil?
        raise ArgumentError, 'name is not a String' unless name.is_a? String
      end

      def validate_pipeline
        raise ArgumentError, 'pipeline is nil' if pipeline.nil?
        raise ArgumentError, 'pipeline is not a Pipeline' unless pipeline.is_a? Pipeline

        pipeline.validate
      end

      def validate_repos
        raise ArgumentError, 'repos is nil' if repos.nil?
        raise ArgumentError, 'repos is not an Array' unless repos.is_a? Array
      end

      def validate_plugins
        raise ArgumentError, 'plugins is nil' if plugins.nil?
        raise ArgumentError, 'plugins is not a Hash' unless plugins.is_a? Hash
      end
    end
  end
end
