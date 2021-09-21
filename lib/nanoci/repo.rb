# frozen_string_literal: true

require 'logging'

require 'nanoci/config/ucs'
require 'nanoci/mixins/provides'

module Nanoci
  ##
  # Source control repository
  class Repo
    # Tag is an id used to identify repo of a project
    # Repo tag must be unique
    # @return [Symbol]
    attr_reader :tag

    # Type of the repo, e.g. 'git', 'svn', etc.
    # @return [String]
    attr_reader :type

    # URI that points to repo storage (on http server, file path, etc.)
    # @return [String]
    attr_reader :uri

    # Name of the branch, tag, commit hash, etc - anything points to a commit
    attr_reader :branch

    # Object specifies authentication against repo
    attr_reader :auth

    # Collection of capabilities requred to run
    # a job against the repo on an agent
    attr_reader :required_agent_capabilities

    # Initializes new instance of Repo
    def initialize(tag:, type:, uri:, auth: nil)
      @log = Logging.logger[self]

      @tag = tag.to_sym
      @type = type.to_sym
      @uri = uri
      @auth = auth
      @required_agent_capabilities = []
      @current_commit = ''
    end

    def repo_cache
      repo_path = File.join(Config::UCS.instance.repo_cache, tag.to_s)
      FileUtils.mkdir_p(repo_path)
      repo_path
    end

    ##
    # Detect changes in source
    # Returns true is there are new changes; false otherwise
    def changes?
      true
    end

    def tip_of_tree(_workdir, _branch)
      ''
    end

    def clone(workdir, opts = {}); end

    def exists?(workdir, opts = {}); end

    def checkout(workdir, branch, opts = {}); end

    def state
      {
        tag: tag,
        current_commit: @current_commit
      }
    end

    def state=(value)
      @log.debug("restoring state of repo #{tag} from #{value}")
      raise "tag #{tag} does not match state tag #{value[:tag]}" \
        unless tag == value[:tag].to_sym

      @current_commit = value[:current_commit]
    end
  end
end
