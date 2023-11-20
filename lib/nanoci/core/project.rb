# frozen_string_literal: true

require 'nanoci'
require 'nanoci/core/pipeline'
require 'nanoci/core/repo'
require 'nanoci/mixins/logger'

module Nanoci
  module Core
    # Represents a project in nano-ci
    class Project
      include Mixins::Logger
      # Storage specific unique Id
      attr_reader :id

      attr_reader :name, :tag, :plugins

      # @return [Array<Repo>]
      attr_reader :repos

      # @return [Nanoci::Pipeline]
      attr_reader :pipeline

      # Source script used to define the project
      # @return [String]
      attr_accessor :src

      # Initializes new instance of [Project]
      # @param name [String]
      # @param tag [Symbol]
      # @param pipeline [Nanoci::Core::Pipeline]
      # @param repos [Array<Nanoci::Core::Repo>]
      def initialize(name:, tag:, pipeline:, repos: [], plugins: {})
        @name = name
        @tag = tag
        @repos = repos
        @pipeline = pipeline
        @pipeline.project = self
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

      def find_repo(tag)
        @repos.select { |x| x.tag == tag }.first
      end

      def find_trigger(tag) = @pipeline.find_trigger_by_tag(tag)

      # Signals the project that a job successfully completed
      def job_complete(stage_tag, job_tag, outputs)
        pipeline.job_complete(stage_tag, job_tag, outputs)
      end

      def job_canceled(stage_tag, job_tag)
        pipeline.job_canceled(stage_tag, job_tag)
      end

      def trigger_fired(trigger_tag, outputs)
        pipeline.trigger_fired(trigger_tag, outputs)
      end

      def memento
        {
          id: id,
          tag: tag,
          pipeline: pipeline.memento
        }
      end

      def memento=(value)
        @id = value[:id]
        @pipeline.memento = value.fetch(:pipeline, {})
      end

      def to_s
        "##{tag}"
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
