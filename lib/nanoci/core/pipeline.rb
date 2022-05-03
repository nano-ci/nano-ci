# frozen_string_literal: true

require 'nanoci/core/stage'

# TODO: fix me
require 'nanoci/trigger'
require 'nanoci/triggers/all'

module Nanoci
  module Core
    # Pipeline is the  class that organizes data flow between project stages.
    class Pipeline
      # Gets the pipeline tag.
      # @return [Symbol]
      attr_reader :tag

      # Gets the pipeline name.
      # @return [String]
      attr_reader :name

      # @return [Array<Trigger>]
      attr_reader :triggers

      # @return [Array<Stage>]
      attr_reader :stages

      # @return [Hash{Symbol => Array<Symbol>}]
      attr_reader :pipes

      # Initializes new instance of Pipeline
      # @param tag [Symbol] Pipeline tag
      # @param name [String] Pipeline name
      # @param triggers [Array<Trigger>] Array of pipeline triggers
      # @param stages [Array<Stage>] Array of pipeline stages
      # @param pipes [Hash{Symbol -> Array<Symbol>}] Hash of pipeline pipes
      def initialize(tag:, name:, triggers:, stages:, pipes:)
        @tag = tag
        @name = name
        @triggers = triggers
        @stages = stages
        @pipes = pipes

        validate
      end

      # Validates the pipeline. Raises ArgumentError if there pipeline is invalid
      def validate
        raise ArgumentError, 'tag is nil' if tag.nil?
        raise ArgumentError, 'tag is not a Symbol' unless tag.is_a? Symbol

        raise ArgumentError, 'name is nil' if name.nil?
        raise ArgumentError, 'name is not a String' unless name.is_a? String

        validate_triggers
        validate_stages
        validate_pipes
      end

      def find_stage(tag)
        stages.select { |s| s.tag == tag }.first
      end

      private

      def validate_triggers
        raise ArgumentError, 'triggers is nil' if triggers.nil?
        raise ArgumentError, 'triggers is not an Array' unless triggers.is_a? Array

        triggers.each do |t|
          unless pipes.key?(t.full_tag)
            @log.warn("trigger #{t.tag} output is not connected to any of stage inputs")
            return false
          end
        end
        true
      end

      def validate_stages
        raise ArgumentError, 'stages is nil' if stages.nil?
        raise ArgumentError, 'stages is not an Array' unless stages.is_a? Array
      end

      def validate_pipes
        raise ArgumentError, 'pipes is nil' if pipes.nil?
        raise ArgumentError, 'pipes is not a Hash' unless pipes.is_a? Hash

        validate_pipe_connections
      end

      def validate_pipe_connections
        pipes.each_pair do |key, value|
          raise ArgumentError, "stage #{key} does not exist" if find_stage(key).nil?

          raise ArgumentError, "pipe #{key} connection array is nil" if value.nil?
          raise ArgumentError, "pipe #{key} connections object is not an Array" unless value.is_a? Array

          values.each do |ps|
            raise ArgumentError, "stage #{ps} does not exist" if find_stage(ps).nil?
          end
        end
      end

      # TODO: move methods below to PipelineDSL

      # Reads pipes from src
      # @param src [Array<String>]
      # @return [Hash<Symbol, Array<Symbol>>]
      def read_pipes(src)
        # @param s [String]
        # @param hash [Hash]
        src.each_with_object(Hash.new { |h, k| h[k] = [] }) do |s, hash|
          read_pipe(s, hash)
        end
      end

      def read_pipe(str, hash)
        pipe_array = str.to_s.split('>>').collect(&:strip)
        pipe_array[0..-2].zip(pipe_array[1..]).each do |m|
          list = hash[m[0].to_sym]
          list.push(m[1].to_sym)
        end
      end
    end
  end
end
