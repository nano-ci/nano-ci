require 'nanoci'
require 'nanoci/build'

class Nanoci
  ##
  # Represents a project in nano-ci
  class Project
    attr_accessor :name
    attr_accessor :tag
    attr_accessor :repos
    attr_accessor :stages
    attr_accessor :variables

    def initialize(hash = {})
      @name = hash['name']
      @tag = hash['tag']
      @repos = {}
      @stages = []
      @variables = {}
    end
  end
end
