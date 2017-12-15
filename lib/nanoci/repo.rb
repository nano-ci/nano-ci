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
    attr_accessor :auth

    ##
    # Array of triggers
    attr_accessor :triggers

    ##
    # Collection of capabilities requred to run
    # a job against the repo on an agent
    attr_reader     :required_agent_capabilities

    def initialize(hash = {})
      @tag  = hash['tag']
      @type = hash['type'] || 'unknown'
      @src  = hash['src']
      @auth = hash['auth']
      @required_agent_capabilities = []
    end
  end
end
