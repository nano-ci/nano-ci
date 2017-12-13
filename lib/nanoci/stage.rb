require 'nanoci/job'

class Nanoci
  ##
  # A stage represents a collection of jobs.
  # Each job is executed concurrently on a free agent
  # All jobs must complete successfully before build proceeds to the next stage
  class Stage
    attr_accessor :tag
    attr_reader   :jobs

    def initialize
      @tag = nil
      @jobs = []
    end

    def self.from_hash(hash)
      stage = Stage.new
      stage.tag = hash['tag']
      hash['jobs'].each { |j| stage.jobs.push(Job.from_hash(j)) } unless hash['jobs'].nil?

      stage
    end
  end
end
