# frozen_string_literal: true

require 'nanoci/stage'
require 'nanoci/trigger'
require 'nanoci/triggers/all'

module Nanoci
  # Pipeline is the  class that organizes data flow between project stages.
  class Pipeline
    # Gets the pipeline tag.
    # @return [Symbol]
    attr_reader :tag

    # Gets the pipeline name.
    # @return [String]
    attr_reader :name

    # Gets the pipeline's project.
    # @return [Nanoci::Project]
    attr_reader :project

    # @return [Array<Nanoci::Trigger>]
    attr_reader :triggers

    # @return [Array<Nanoci::Stage>]
    attr_reader :stages

    # @return [Hash{Symbol => Array<Symbol>}]
    attr_reader :pipes

    # Initializes new instance of Pipeline
    # @param src [Hash]
    # @param project [Nanoci::Project]
    def initialize(src, project)
      @src = src
      @tag = @src[:tag]
      @name = @src[:name]
      @project = project
      @triggers = read_triggers(@src.fetch(:triggers, []))
      @stages = read_stages(@src.fetch(:stages, []))
      @pipes = read_pipes(@src.fetch(:pipes, []))
    end

    private

    # Reads triggers from src hash
    # @param src [Array<Hash>]
    # @return [Array<Nanoci::Trigger>]
    def read_triggers(src)
      src.collect do |s|
        Trigger.resolve(s[:type]).new(s)
      end
    end

    # Reads stages from src hash
    # @param src [Array<Hash>]
    # @return [Array<Nanoci::Stage>]
    def read_stages(src)
      src.collect { |s| Stage.new(s, self) }
    end

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
