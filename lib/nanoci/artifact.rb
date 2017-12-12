class Nanoci
  ##
  # An artifact is the output of job and may contains files or folders
  class Artifact
    attr_accessor :tag
    attr_accessor :path
    attr_accessor :pattern

    def initialize
      @tag = nil
      @path = nil
      @pattern = nil
    end
  end
end
