require 'nanoci/artifact'
require 'nanoci/task'

class Nanoci
  ##
  # A job is a collection of tasks to run actions and produce artifacts
  class Job
    attr_accessor :tag
    attr_reader   :tasks
    attr_reader   :artifacts

    def initialize
      @tag = nil
      @tasks = []
      @artifacts = []
    end

    def self.from_hash(hash)
      job = Job.new
      job.tag = hash['tag']
      hash['tasks'].each { |t| job.tasks.push(Task.from_hash(t)) } unless hash['tasks'].nil?
      hash['artifacts'].each { |a| job.artifacts.push(Artifact.from_hash(a)) } unless hash['artifacts'].nil?
    end
  end
end
