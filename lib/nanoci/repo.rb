# frozen_string_literal: true

class Nanoci
  ##
  # Source control repository
  class Repo
    class << self
      def types
        @types ||= {}
      end
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
    # Name of the branch, tag, commit hash, etc - anything points to a commit
    attr_accessor :branch

    ##
    # Object specifies authentication against repo
    attr_accessor :auth

    attr_accessor :current_commit

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
    def changes?(_env)
      true
    end

    def tip_of_tree(_branch, _env)
      ''
    end

    def clone(env, opts = {}); end

    def exists?(env, opts = {}); end

    def checkout(branch, env, opts = {}); end

    def state
      {
        tag: @tag,
        current_commit: @current_commit
      }
    end

    def state=(value)
      raise "tag #{tag} does not match state tag #{value[:tag]}" \
        unless tag == value[:tag]
      @current_commit = value[:current_commit]
    end
  end
end
