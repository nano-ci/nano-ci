class Nanoci
  class Trigger
    @types = {}

    def self.types
      @types
    end

    attr_accessor :type

    def initialize(hash = {})
      @type = hash['type']
    end

    def run(repo, project)
      @repo = repo
      @project = project
    end
  end
end
