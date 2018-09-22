# frozen_string_literal: true

require 'fileutils'
require 'tempfile'

require 'nanoci/repo'
require 'nanoci/tool_error'
require 'nanoci/tool_process'

class Nanoci
  class Plugins
    class Git
      # Git repo class. Implements interface of Nanoci::Repo class
      class RepoGit < Repo
        provides 'git'

        GIT_CAP = 'tools.git'
        SSH_CAP = 'tools.ssh'
        DEFAULT_BRANCH = 'master'

        attr_reader :trusted_host_keys



        def initialize(definition)
          super(definition)
          @branch ||= DEFAULT_BRANCH
          @trusted_host_keys = definition.params[:trusted_host_keys]
          required_agent_capabilities.push(GIT_CAP)
          required_agent_capabilities.push(SSH_CAP)
        end

        def in_repo_cache(env)
          repo_path = File.join(env['repo_cache'], tag.to_s)
          FileUtils.mkdir_p(repo_path) unless Dir.exist? repo_path
          Dir.chdir(repo_path) do
            yield
          end
        end

        def changes?(env)
          in_repo_cache(env) do
            update(env)
            tip = tip_of_tree(@branch, env)
            return tip != @current_commit
          end
        end

        def update(env)
          clone(env, no_checkout: true) unless exists?(env)
          fetch(env)
        end

        def tip_of_tree(branch, env = {})
          git_process = git("rev-parse --verify origin/#{branch}", env)
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
          branch ||= @branch
          git("checkout #{branch}", env, opts)
        end

        private

        def auth
          @definition.params[:auth]
        end

        def git(cmd, env, opts = {})
          git_path = env[GIT_CAP]
          raise "Missing #{GIT_CAP} capability" if git_path.nil?
          unless auth[:ssh].nil?
            ssh_opts = ["-i #{auth[:ssh]}"]
            unless auth[:trusted_host_keys].nil?
              trusted_keys = auth[:trusted_host_keys]
              known_hosts = create_ssh_known_hosts(hostname, trusted_keys)
              ssh_opts.push("-o UserKnownHostsFile=\"#{known_hosts}\"")
            end
            ssh = "#{env[SSH_CAP]} #{ssh_opts.join(' ')}"
            opts[:env] ||= {}
            opts[:env]['GIT_SSH_COMMAND'] = ssh
          end
          ToolProcess.run("\"#{git_path}\" #{cmd}", opts).wait
        end

        def create_ssh_known_hosts(hostname, trusted_keys)
          content = trusted_keys.map(&method(:format_ssh_known_host_entry))
                                .join("\n")
          file = Tempfile.new('known_hosts')
          file << content
          file.flush
          file.path
        end

        def format_ssh_known_host_entry(hostname, trusted_key)
          "#{hostname} ssh-rsa #{trusted_key}"
        end
      end
    end
  end
end
