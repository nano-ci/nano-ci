require 'nanoci'

class Nanoci
  ##
  # Represents a project in nano-ci
  class Project
    attr_accessor :name
    attr_accessor :tag
    attr_accessor :stages

    attr_reader :repos

    def repos=(value)
      raise 'value is not a Hash' unless value.is_a? Hash
      @repos = value
    end

    attr_reader :variables

    def variables=(value)
      raise 'value is not a Hash' unless value.is_a? Hash
      @variables = value
    end

    def initialize(hash = {})
      @name = hash['name']
      @tag = hash['tag']
      @repos = {}
      @stages = []
      @variables = {}
    end
  end
end
