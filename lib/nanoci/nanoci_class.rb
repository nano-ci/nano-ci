# frozen_string_literal: true

require 'nanoci/resource_map'

# Root class of nano-ci
class Nanoci
  class << self
    attr_accessor :config

    # @return [ResourceMap]
    def resources
      @resources ||= ResourceMap.new
    end
  end
end
