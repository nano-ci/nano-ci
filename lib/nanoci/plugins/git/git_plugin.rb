# frozen_string_literal: true

require 'nanoci/plugins/plugin_base'

require_relative 'git_command'

module Nanoci
  module Plugins
    module Git
      # [Nanoci::Plugins::Git::GitPlugin] provides acceess to git command.
      class GitPlugin < Nanoci::Plugins::PluginBase
        def augment(extension_point)
          super

          extension_point.add_command(:git, method(:git).to_proc)
        end

        private

        # Gets an instance of git command configured for the specified repo.
        def git(command_host, project, repo)
          GitCommand.new(command_host, project, repo)
        end
      end
    end
  end
end

Nanoci::PluginHost.register_plugin(:'command.git', Nanoci::Plugins::Git::GitPlugin)
