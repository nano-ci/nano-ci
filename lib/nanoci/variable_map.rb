# frozen_string_literal: true

require 'nanoci/variable'

module Nanoci
  # VariableMap is a Hash-like structure to store Variables
  class VariableMap
    def initialize(src = nil)
      @data = initialize_from(src)
    end

    def to_hash
      @data.to_h
    end

    def [](key)
      raise 'key is not a Symbol' unless key.is_a? Symbol

      @data[key]
    end

    def []=(key, value)
      raise 'key is not a Symbol' unless key.is_a? Symbol

      @data[key] = to_variable(key, value)
    end

    def include?(data)
      case data
      when Hash
        data.each do |k, v|
          return false unless @data.key?(k) && @data[k] == to_variable(k, v)
        end
        true
      when Symbol
        @data.key?(k)
      else
        false
      end
    end

    def inspect
      @data.inspect
    end

    private

    # Returns data hash from valid source data
    def initialize_from(src)
      case src
      when nil
        {}
      when Hash
        initialize_from_hash(src)
      when VariableMap
        initialize_from_variable_map(src)
      else
        raise 'unsupported type'
      end
    end

    def initialize_from_hash(src)
      data = src.map do |k, v|
        raise 'hash key is not a Symbol' unless k.is_a?(Symbol)

        [k, to_variable(k, v)]
      end
      data.to_h
    end

    def initialize_from_variable_map(src)
      initialize_from_hash(src.to_hash)
    end

    def to_variable(key, value)
      case value
      when Variable
        value
      else
        Variable.new(key, value)
      end
    end
  end
end
