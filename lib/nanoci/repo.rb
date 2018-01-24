class Nanoci
  ##
  # Source control repository
  class Repo
    @types = {}

    def self.types
      @types
    end

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
    attr_reader   :required_agent_capabilities

    def initialize(hash = {})
      @tag  = hash['tag']
      @type = hash['type'] || 'unknown'
      @src  = hash['src']
      @auth = hash['auth']
      @required_agent_capabilities = []
      @current_commit = ''
    end

    ##
    # Detect changes in source
    # Returns true is there are new changes; false otherwise
    def detect_changes(_agent)
      true
    end

    ##
    # Returns commit id of tip of tree
    def current_commit
      @current_commit
    end

    def current_commit=(value)
      @current_commit = value
    end

    def tip_of_tree(_branch, _agent)
      ''
    end

    def clone(_agent, _opts = {}); end

    def exists?(_agent, _opts = {}); end

    def checkout(_branch, _agent, _opts = {}); end
  end
end
