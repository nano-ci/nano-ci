# frozen_string_literal: true

module Nanoci
  module Plugins
    module Git
      # Class [GitCommand] implements git commands.
      class GitCommand
        # Initializes new instance of [GitCommand]
        # @param command_host [Nanoci::CommandHost]
        # @param repo [Nanoci::Repo]
        def initialize(command_host, repo)
          @command_host = command_host
          @repo = repo
        end
      end
    end
  end
end