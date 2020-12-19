# frozen_string_literal: true

require 'nanoci/stage'
require 'nanoci/trigger'

module Nanoci
  # Pipeline is the  class that organizes data flow between project stages.
  class Pipeline
    # Initializes new instance of Pipeline
    # @param src [Hash]
    def initialize(src)
      @src = src
      @triggers = read_triggers(@src.fetch(:triggers, []))
      @stages = read_stages(@src.fetch[:stages, []])
      @pipes = read_pipes(@src.fetch[:pipes, []])
    end

    private

    # Reads triggers from src hash
    # @param src [Array<Hash>]
    # @return [Array<Nanoci::Trigger>]
    def read_triggers(src)
      src.collect { |s| Trigger.resolve(s[:type]).new(s) }
    end

    # Reads stages from src hash
    # @param src [Array<Hash>]
    # @return [Array<Nanoci::Stage>]
    def read_stages(src)
      src.collect { |s| Stage.new(s) }
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

    def read_pipe(hash, str)
      pipe_array = str.to_s.split('>>').collect(&:strip)
      pipe_array[0..-2].zip(pipe_array[1..]).each do |m|
        list = hash[m[0].to_sym]
        list.push(m[1].to_sym)
      end
    end
  end
end
