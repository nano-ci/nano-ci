require 'nanoci/repo'
require 'nanoci/stage'
require 'nanoci/variable'

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
      @repos = []
      @stages = []
      @variables = []
    end

    def trigger_build(trigger)
      puts "Project #{name} build is triggerred by #{trigger} at #{Time.now}"
    end
  end
end
