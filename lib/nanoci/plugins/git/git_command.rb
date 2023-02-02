# frozen_string_literal: true

require 'set'
require 'tempfile'

module Nanoci
  module Plugins
    module Git
      # Class [GitCommand] implements git commands.
      class GitCommand
        GIT_ASKPASS_SRC = <<~GIT_ASKPASS
          #!/bin/bash
          case "$1" in
            Username*) exec echo "$NANOCI_GIT_USERNAME" ;;
            Password*) exec echo "$NANOCI_GIT_PASSWORD" ;;
          esac
        GIT_ASKPASS

        @commands = Set.new(%i[
                              add
                              am
                              apply
                              archive
                              bisect
                              blame
                              branch
                              bundle
                              checkout
                              cherry_pick
                              clean
                              clone
                              commit
                              describe
                              diff
                              fetch
                              filter_branch
                              format_patch
                              fsck
                              gc
                              grep
                              init
                              log
                              merge
                              mv
                              pull
                              push
                              range_diff
                              rebase
                              reflog
                              remote
                              request_pull
                              reset
                              revert
                              rm
                              send_email
                              shortlog
                              show
                              stash
                              status
                              submodule
                              tag
                            ]).freeze

        class << self
          attr_reader :commands
        end
        # Initializes new instance of [GitCommand]
        # @param command_host [Nanoci::CommandHost]
        # @param project [Nanoci::Project]
        # @param repo [Nanoci::Core::Repo]
        def initialize(command_host, project, repo)
          @command_host = command_host
          @project = project
          @repo = repo
        end

        attr_reader :repo

        def clone(args = '')
          run_git('clone', "#{repo.uri} #{args}")
        end

        def ls_remote(args = '')
          result = run_git('ls-remote', "#{repo.uri} #{args}")
          result.stdout.split("\n").to_h { |v| v.split("\t").reverse }
        end

        def method_missing(method_name, *args, &_block)
          return unless GitCommand.commands.include?(method_name.to_sym)

          command_name = method_name.to_s.sub('_', '-')

          if args.empty?
            run_git(command_name)
          else
            run_git(command_name, args[0])
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          GitCommand.commands.include?(method_name.to_sym) || super
        end

        private

        def run_git(command, args = '')
          env = { 'GIT_TERMINAL_PROMPT' => 0 }
          setup_https_auth(repo, env) if repo.auth&.key?(:username) && repo.auth&.key?(:password)
          setup_ssh_auth(repo, env) if repo.auth&.key?(:ssh_key)
          @command_host.execute_shell("git #{command} #{args}", env: env)
        end

        def setup_https_auth(repo, env)
          git_askpass_tmp = Tempfile.new(['nanoci-git-askpass', '.sh'])
          git_askpass_tmp << GIT_ASKPASS_SRC
          git_askpass_tmp.close(false)
          File.chmod(0o700, git_askpass_tmp.path)
          env['GIT_ASKPASS'] = git_askpass_tmp.path
          env['NANOCI_GIT_USERNAME'] = repo.auth[:username]
          env['NANOCI_GIT_PASSWORD'] = repo.auth[:password]
        end

        def setup_ssh_auth(repo, env)
          env['GIT_SSH_COMMAND'] = "SSH_ASKPASS=false SSH_ASKPASS_REQUIRE=force ssh -i #{repo.auth[:ssh_key]}"
        end
      end
    end
  end
end
