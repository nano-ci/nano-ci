# frozen_string_literal: true

require 'fileutils'
require 'tempfile'

require 'nanoci/repo'
require 'nanoci/tool_error'
require 'nanoci/tool_process'

module Nanoci
  class Plugins
    class Git
      # Git repo class. Implements interface of Nanoci::Repo class
      class RepoGit < Repo
        provides 'git'

        GIT_CAP = :'tools.git'
        SSH_CAP = :'tools.ssh'
        DEFAULT_BRANCH = 'master'

        attr_reader :trusted_host_keys

        def branch
          definition.branch || DEFAULT_BRANCH
        end

        def initialize(definition)
          super(definition)
          required_agent_capabilities.push(GIT_CAP)
          required_agent_capabilities.push(SSH_CAP)
        end

        def changes?
          workdir = repo_cache
          update(workdir)
          tip_of_tree(workdir, branch) != @current_commit
        end

        def update(workdir)
          if exists?(workdir)
            fetch(workdir)
          else
            clone(workdir, no_checkout: true)
          end
        end

        def tip_of_tree(workdir, branch)
          git_process = git("rev-parse --verify origin/#{branch}", workdir)
          git_process.output
        end

        def clone(workdir, opts = {})
          args = []
          args.push '--no-checkout' if opts[:no_checkout]
          args.push src
          args.push '.'
          cmd = "clone #{args.join(' ')}"
          git(cmd, workdir, opts)
        end

        def fetch(workdir, opts = {})
          git('fetch origin', workdir, opts)
        end

        def exists?(workdir, opts = {})
          git('status', workdir, opts)
        rescue ToolError
          false
        end

        def checkout(workdir, branch, opts = {})
          branch ||= @branch
          git("checkout #{branch}", workdir, opts)
        end

        private

        def auth
          @definition.params[:auth]
        end

        def git(cmd, workdir, opts = {})
          agent_capabilities = Config::UCS.instance.agent_capabilities
          git_path = agent_capabilities[GIT_CAP]
          raise "Missing #{GIT_CAP} capability" if git_path.nil?

          unless auth[:ssh].nil?
            ssh_opts = ["-i #{auth[:ssh]}"]
            if auth.fetch(:validate_server_key, false)
              trusted_keys = auth[:trusted_host_keys]
              known_hosts = create_ssh_known_hosts(hostname, trusted_keys)
              ssh_opts.push("-o UserKnownHostsFile=\"#{known_hosts}\"")
            else
              ssh_opts.push('-o StrictHostKeyChecking=no')
            end
            ssh = "#{agent_capabilities[SSH_CAP]} #{ssh_opts.join(' ')}"
            opts[:env] ||= {}
            opts[:env]['GIT_SSH_COMMAND'] = ssh
          end
          opts[:chdir] = workdir
          ToolProcess.run("\"#{git_path}\" #{cmd}", opts).wait
        end

        def create_ssh_known_hosts(hostname, trusted_keys)
          content = trusted_keys.map(&->(k) { format_ssh_known_host_entry(hostname, k) })
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
