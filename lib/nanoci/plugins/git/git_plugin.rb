# frozen_string_literal: true

require 'nanoci/plugins/command_plugin'
require 'nanoci/plugins/git/git_command'

module Nanoci
  module Plugins
    module Git
      # The module contains methods implementing git command DSL.
      module GitCommandModule
        # Gets an instance of git command configured for the specified repo.
        def git
          GitCommand.new(self, project)
        end
      end

      # [Nanoci::Plugins::Git::GitPlugin] provides acceess to git command.
      class GitPlugin < Nanoci::Plugins::CommandPlugin
        def initialize
          super
          @command_module = GitCommandModule
        end
      end
    end
  end
end

Nanoci::PluginHost.register_plugin(:'command.git', Nanoci::Plugins::Git::GitPlugin)
