require 'nanoci/repo'

class Nanoci
  class Plugins
    class Git
      class RepoGit < Repo
        def initialize(hash)
          super(hash)
        end
      end
    end
  end
end
