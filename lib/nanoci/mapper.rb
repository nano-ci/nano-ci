# frozen_string_literal: true

module Nanoci
  class Mapper
    class Rule
      attr_reader :from, :to, :with

      def initialize(from, to, with)
        @from = from
        @to = to
        @with = with
      end
    end

    class RulesBuilder
      def initialize
        @rules = []
        @post_action = nil
      end

      def build
        { rules: @rules, post_action: @post_action }
      end

      def map(from, to:, with: nil)
        @rules[from] = Rule.new(from, to, with)
      end

      def post_action(&block)
        @post_action = block
      end
    end

    def initialize
      builder = RulesBuilder.new
      yield builder
      r = builder.build
      @rules = r[:rules]
      @post_action = r[:post_action]
      @props_readers = { Hash => ->(x) { x } }.freeze
      @props_writers = { Hash => method(:map_to_hash) }.freeze
    end

    def map(from, to)
      raise ArgumentError, "type #{from.class} is not supported" unless @props_readers.key?(from.class)
      raise ArgumentError, "type #{to.class} is not supported" unless @props_writers.key?(from.class)

      props = @props_readers[from.class].call(from)
      to = @props_writers[to.class].call(props, to)
      @post_action&.call(to)
      to
    end

    private

    def map_to_hash(props, hash)
      props.each do |k, v|
        rule = @rules[l]
        if rule.nil?
          hash[k] = v
        else
          hash[rule.to] = v
        end
      end
    end
  end
end
