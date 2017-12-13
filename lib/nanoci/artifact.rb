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

    def self.from_hash(hash)
      artifact = Artifact.new
      artifact.tag = hash['tag']
      artifact.path = hash['path']
      artifact.pattern = Regexp.new(hash['pattern']) unless hash['pattern'].nil?
    end
  end
end
