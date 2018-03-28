# frozen_string_literal: true

require 'nanoci/plugin'
require 'nanoci/plugins/git/repo_git'
require 'nanoci/repo'

class Nanoci
  class Plugins
    # Entry class for Git plugin
    class Git
      # Git plugin class. Registers types supported by Git plugin
      class PluginGit < Plugin
        def initialize
          Repo.types['git'] = RepoGit
        end
      end

      Plugin.plugins.push PluginGit
    end
  end
end
