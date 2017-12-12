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
    # Repo provider class must override the accessor and return proper value
    attr_reader   :type

    ##
    # URI that points to repo storage (on http server, file path, etc.)
    attr_accessor :src

    ##
    # Object specifies authentication against repo
    attr_reader   :auth

    ##
    # Collection of capabilities requred to run
    # a job against the repo on an agent
    # Repo provider class must override the accessor and return proper value
    attr_reader   :required_agent_capabilities

    def initialize
      @tag = nil
      @type = 'unknown'
      @src = nil
      @auth = nil
      @required_agent_capabilities = []
    end
  end
end
