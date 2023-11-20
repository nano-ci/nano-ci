# frozen_string_literal: true

require 'nanoci/core/pipeline'
require 'nanoci/dsl/stage_dsl'
require 'nanoci/dsl/trigger_dsl'

module Nanoci
  module DSL
    # PipelineDSL class contains methods to support nano-ci pipeline DSL.
    class PipelineDSL
      class << self
        def dsl_types
          @dsl_types ||= {}
        end

        def add_dsl_type(type, clazz)
          dsl_types[type] = clazz
        end
      end

      def initialize(tag, name)
        @tag = tag
        @name = name
        @triggers = []
        @stages = []
        @pipes = []
        @hooks = {}
      end

      # Defines a pipeline trigger
      # @param tag [Symbol] unique tag of the trigger
      # @param type [Symbol] trigger type
      def trigger(tag, type, &block)
        raise "trigger #{tag} is missing definition block" if block.nil?
        raise "trigger type #{type} is not supported" unless PipelineDSL.dsl_types.key?(type)

        trigger_dsl_class = PipelineDSL.dsl_types[type]
        trigger_dsl = trigger_dsl_class.new(tag)
        trigger_dsl.instance_eval(&block)
        @triggers.push(trigger_dsl)
      end

      def stage(tag, **params, &block)
        raise "stage #{tag} is missing definition block" if block.nil?

        stage_dsl = StageDSL.new(@component_factory, tag, **params)
        stage_dsl.instance_eval(&block)
        @stages.push(stage_dsl)
      end

      def pipe(pipe)
        @pipes.push(pipe)
      end

      %i[after_failure].each do |hook|
        code = <<-CODE
          def #{hook}(&block)
            raise 'pipeline hook #{hook} is missing block' if block.nil?
            @hooks[:#{hook}] = block
          end
        CODE
        class_eval(code)
      end

      def build
        Core::Pipeline.new(
          tag: @tag,
          name: @name,
          triggers: @triggers.collect(&:build),
          stages: @stages.collect { |x| x.build(@hooks) },
          pipes: read_pipes(@pipes),
          hooks: @hooks
        )
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
end
