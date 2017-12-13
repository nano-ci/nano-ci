class Nanoci
  ##
  # Source control repository
  class Repo
    ##
    # Tag is an id used to identify repo of a project
    # Repo tag must be unique
    attr_accessor :tag

    ##
    # Type of the repo, e.g. 'git', 'svn', etc.
    attr_accessor :type

    ##
    # URI that points to repo storage (on http server, file path, etc.)
    attr_accessor :src

    ##
    # Object specifies authentication against repo
    attr_accessor   :auth

    ##
    # Collection of capabilities requred to run
    # a job against the repo on an agent
    attr_reader   :required_agent_capabilities

    def initialize
      @tag  = nil
      @type = 'unknown'
      @src  = nil
      @auth = nil
      @required_agent_capabilities = []
    end

    def self.from_hash(hash)
      repo = Repo.new
      repo.tag  = hash['tag']
      repo.type = hash['type']
      repo.src  = hash['src']
      repo.auth = hash['auth']
      repo
    end
  end
end
