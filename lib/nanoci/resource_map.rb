# frozen_string_literal: true

class Nanoci
  ##
  # A resource map holds mappings of resource type to ruby class
  class ResourceMap
    ##
    # Initializes new instance of ResourceMap
    def initialize
      @map = {}
    end

    # Adds a new entry to the map
    # @param key [String] key of the resource
    # @param klass [Class] class implementing the resource
    def set(key, klass)
      key = key.to_sym
      raise "duplicate key #{key}" if @map.key? key
      @map[key] = klass
    end

    ##
    # Gets an entry from the map
    # @param key [String] key of the resource
    # @return [Class] class implementing the resource
    def get(key)
      key = key.to_sym
      raise "missing resource #{key}" unless @map.key? key
      @map[key]
    end
  end
end
