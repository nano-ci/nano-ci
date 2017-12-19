require 'nanoci/plugin'
require 'nanoci/plugins/git/repo_git'
require 'nanoci/repo'

class Nanoci
  class Plugins
    class Git
      class PluginGit < Plugin
        def initialize
          Repo.types['git'] = RepoGit
        end
      end

      Plugin.plugins.push PluginGit
    end
  end
end
