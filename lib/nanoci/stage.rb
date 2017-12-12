class Nanoci
  ##
  # A stage represents a collection of jobs.
  # Each job is executed concurrently on a free agent
  # All jobs must complete successfully before build proceeds to the next stage
  class Stage
    attr_accessor :tag
    attr_reader   :jobs
  end
end
