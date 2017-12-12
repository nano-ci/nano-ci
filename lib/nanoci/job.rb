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
  end
end
