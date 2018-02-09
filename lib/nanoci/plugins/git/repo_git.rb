require 'fileutils'

require 'nanoci/repo'
require 'nanoci/tool_error'
require 'nanoci/tool_process'

class Nanoci
  class Plugins
    class Git
      class RepoGit < Repo
        GIT_CAP = 'tools.git'.freeze
        SSH_CAP = 'tools.ssh'.freeze
        DEFAULT_BRANCH = 'master'.freeze

        def initialize(hash = {})
          super(hash)
          @branch ||= DEFAULT_BRANCH
          required_agent_capabilities.push(GIT_CAP)
        end

        def detect_changes(env)
          repo_path = File.join(env['repo_cache'], tag)
          FileUtils.mkdir_p(repo_path) unless Dir.exist? repo_path
          Dir.chdir(repo_path) do
            clone(env, no_checkout: true) unless exists?(env)
            fetch(env)
            tip = tip_of_tree("origin/#{@branch}", env)
            if tip != @current_commit
              @current_commit = tip
              return true
            end
          end
          false
        end

        def tip_of_tree(branch, env={})
          git_process = git("rev-parse --verify #{branch}", env)
          git_process.output
        end

        def clone(env, opts = {})
          args = []
          args.push '--no-checkout' if opts[:no_checkout]
          args.push src
          args.push '.'
          cmd = "clone #{args.join(' ')}"
          git(cmd, env, opts)
        end

        def fetch(env, opts = {})
          git('fetch origin', env, opts)
        end

        def exists?(env, opts = {})
          git('status', env, opts)
        rescue ToolError
          false
        end

        def checkout(branch, env, opts = {})
          branch = branch || @branch
          git("checkout #{branch}", env, opts)
        end

        private

        def git(cmd, env, opts = {})
          git_path = env[GIT_CAP]
          raise "Missing #{GIT_CAP} capability" if git_path.nil?
          unless @auth['ssh'].nil?
            ssh = "#{env[SSH_CAP]} -i #{@auth['ssh']}"
            opts[:env] ||= {}
            opts[:env]['GIT_SSH_COMMAND'] = ssh
          end
          process = ToolProcess.run "\"#{git_path}\" #{cmd}", opts
          process.wait
          process
        end
      end
    end
  end
end
