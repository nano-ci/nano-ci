# frozen_string_literal: true

require 'nanoci/plugins/command_plugin'
require 'nanoci/plugins/git/git_command'

module Nanoci
  module Plugins
    module Git
      # [Nanoci::Plugins::Git::GitPlugin] provides acceess to git command.
      class GitPlugin < Nanoci::Plugins::CommandPlugin
        # Gets an instance of git command configured for the specified repo.
        def git(command_host, project)
          GitCommand.new(command_host, project)
        end
      end
    end
  end
end

Nanoci::PluginHost.register_plugin(:'command.git', Nanoci::Plugins::Git::GitPlugin)
