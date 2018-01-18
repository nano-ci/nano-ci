require 'nanoci/repo'

class Nanoci
  class Plugins
    class Git
      class RepoGit < Repo
        def initialize(hash={})
          super(hash)
          required_agent_capabilities.push('tools.git')
        end
      end
    end
  end
end
