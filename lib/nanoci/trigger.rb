class Nanoci
  class Trigger
    @types = {}

    def self.types
      @types
    end

    attr_accessor :type

    def initialize(repo, project, hash = {})
      @repo = repo
      @project = project
      @type = hash['type']
    end

    def run ; end
  end
end
