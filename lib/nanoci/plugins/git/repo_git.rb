require 'fileutils'
require 'open4'

require 'nanoci/repo'
require 'nanoci/tool_process'

class Nanoci
  class Plugins
    class Git
      class RepoGit < Repo
        GIT_CAP = 'tools.git'.freeze
        DEFAULT_BRANCH = 'master'.freeze

        def initialize(hash = {})
          super(hash)
          @branch = @branhc || @DEFAULT_BRANCH
          required_agent_capabilities.push(GIT_CAP)
        end

        def detect_changes(agent)
          repo_path = File.join(agent.repo_cache, tag)
          FileUtils.mkdir_p(repo_path) unless Dir.exist? repo_path
          Dir.chdir(repo_path) do
            clone(agent, no_checkout: true) unless exists?(agent)
            fetch(agent)
            return tip_of_tree("origin/#{branch}", agent) != current_commit
          end
        end

        def tip_of_tree(branch, agent)
          git_process = git("rev-parse --verify #{branch}", agent)
          git_process.ok? ? git_process.output : nil
        end

        def clone(agent, opts = {})
          args = []
          args.push '--no-checkout' if opts[:no_checkout]
          args.push src
          args.push '.'
          cmd = "clone #{Array.join(args, ' ')}"
          git(cmd, agent, opts)
        end

        def fetch(agent)
          git('fetch origin', agent, opts)
        end

        def exists?(agent)
          git_process = git('status', agent, opts)
          true
        end

        def checkout(branch, agent, opts)
          git("checkout #{branch}", agent, opts)
        end

        private

        def git(cmd, agent, opts = {})
          git_path = agent.capability(GIT_CAP)
          raise "Missing #{GIT_CAP} capability" if git_path.nil?
          ToolProcess.new "#{git_path} cmd", opts
        end
      end
    end
  end
end
