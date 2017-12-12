class Nanoci
  ##
  # Represents a project in nano-ci
  class Project
    attr_accessor :name
    attr_reader :repos
    attr_reader :stages
    attr_reader :variables
    attr_reader :feature_branches

    def initialize
      @name = nil
      @repos = []
      @stages = []
      @variables = []
      @feature_branches = nil
    end
  end
end
