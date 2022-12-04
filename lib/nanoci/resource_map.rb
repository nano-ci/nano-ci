# frozen_string_literal: true

module Nanoci
  # A resource map holds mappings of resource type to ruby class
  class ResourceMap
    # Initializes new instance of ResourceMap
    def initialize
      @map_stack = []
      @map_stack.push({})
    end

    # Removes all entries from the map
    def clean
      @map_stack = []
      @map_stack.push({})
    end

    def push
      @map_stack.push({})
    end

    def pop
      @map_stack.pop
    end

    # Adds a new entry to the map
    # @param key [String] key of the resource
    # @param klass [Class] class implementing the resource
    def set(key, klass)
      key = key.to_sym
      raise "duplicate key #{key}" if @map_stack.last.key? key

      @map_stack.last[key] = klass
    end

    # Gets an entry from the map
    # @param key [String] key of the resource
    # @return [Class] class implementing the resource
    def get(key)
      key = key.to_sym
      item = @map_stack.reverse.map { |x| x[key] }.compact.first
      raise "missing resource #{key}" if item.nil?

      item
    end
  end
end
