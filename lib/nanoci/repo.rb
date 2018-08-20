# frozen_string_literal: true

require 'nanoci/mixins/provides'

class Nanoci
  ##
  # Source control repository
  class Repo
    extend Mixins::Provides

    class << self
      # Registers a provider of a resource
      # @param tag [String] tag to identify the provider
      def provides(tag)
        super("repo:#{tag}")
      end

      # Returns the provider of a resource
      # @param tag [String] tag to identify the provider
      # @return [Class] class implementing the resource
      def resolve(tag)
        super("repo:#{tag}")
      end
    end

    ##
    # Repo definition
    # @return [RepoDefinition]
    attr_reader :definition

    ##
    # Tag is an id used to identify repo of a project
    # Repo tag must be unique
    # @return [Symbol]
    def tag
      @definition.tag
    end

    ##
    # Type of the repo, e.g. 'git', 'svn', etc.
    # @return [String]
    def type
      @definition.type
    end

    ##
    # Boolean flag that indicates if this is the main repo of a project
    # @return [Boolean]
    def main
      @definition.main
    end

    ##
    # URI that points to repo storage (on http server, file path, etc.)
    # @return [String]
    def src
      @definition.src
    end

    ##
    # Name of the branch, tag, commit hash, etc - anything points to a commit
    def branch
      @definition.branch
    end

    ##
    # Object specifies authentication against repo
    def auth
      @definition.auth
    end

    attr_accessor :current_commit

    ##
    # Array of triggers
    def triggers
      @definition.triggers
    end

    ##
    # Collection of capabilities requred to run
    # a job against the repo on an agent
    attr_reader :required_agent_capabilities

    ##
    # Initializes new instance of Repo
    # @param definition [RepoDefinition]
    def initialize(definition)
      @definition = definition
      @tag  = @definition.tag
      @type = @definition.type
      @main = @definition.main
      @src  = @definition.src
      @auth = @definition.auth
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
        unless tag == value[:tag].to_sym
      @current_commit = value[:current_commit]
    end
  end
end
