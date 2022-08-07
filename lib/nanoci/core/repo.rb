# frozen_string_literal: true

require 'logging'

require 'nanoci/config/ucs'
require 'nanoci/mixins/provides'

module Nanoci
  module Core
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

      # Initializes new instance of Repo
      def initialize(tag:, type:, uri:, auth: nil)
        @log = Logging.logger[self]

        @tag = tag.to_sym
        @type = type.to_sym
        @uri = uri
        @auth = auth
      end
    end
  end
end
