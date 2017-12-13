require 'nanoci/repo'
require 'nanoci/stage'
require 'nanoci/variable'

class Nanoci
  ##
  # Represents a project in nano-ci
  class Project
    attr_accessor :name
    attr_accessor :tag
    attr_reader   :repos
    attr_reader   :stages
    attr_reader   :variables
    attr_reader   :feature_branches

    def initialize
      @name = nil
      @repos = []
      @stages = []
      @variables = []
      @feature_branches = nil
    end

    def self.from_hash(hash)
      project = Project.new
      project.name = hash['name']
      project.tag = hash['tag']
      hash['repos'].each { |r| project.repos.push(Repo.from_hash(r)) } unless hash['repos'].nil?
      hash['stages'].each { |s| project.stages.push(Stage.from_hash(s)) } unless hash['stages'].nil?
      hash['variables'].each { |v| project.variables.push(Variable.from_hash(v)) } unless hash['variables'].nil?
      project
    end
  end
end
