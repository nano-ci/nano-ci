require 'nanoci/artifact'
require 'nanoci/task'

class Nanoci
  ##
  # A job is a collection of tasks to run actions and produce artifacts
  class Job
    attr_accessor :tag
    attr_accessor :tasks
    attr_accessor :artifacts

    def initialize(hash = {})
      @tag = hash['tag']
      @tasks = []
      @artifacts = []
    end
  end
end
