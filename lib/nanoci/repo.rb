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
    def tag
      @src[:tag]
    end

    # Type of the repo, e.g. 'git', 'svn', etc.
    # @return [String]
    def type
      @src[:type]
    end

    # URI that points to repo storage (on http server, file path, etc.)
    # @return [String]
    def uri
      @src[:uri]
    end

    # Name of the branch, tag, commit hash, etc - anything points to a commit
    def branch
      @src.fetch(:branch, nil)
    end

    # Object specifies authentication against repo
    def auth
      @src.fetch(:auth, nil)
    end

    # Collection of capabilities requred to run
    # a job against the repo on an agent
    attr_reader :required_agent_capabilities

    # Initializes new instance of Repo
    # @param src [Hash]
    def initialize(src)
      @log = Logging.logger[self]

      @src = src
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
