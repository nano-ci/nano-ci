# frozen_string_literal: true

require 'set'

module Nanoci
  module Plugins
    module Git
      # Class [GitCommand] implements git commands.
      class GitCommand
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
        # @param project [Nanoci::project]
        def initialize(command_host, project)
          @command_host = command_host
          @project = project
        end

        def clone(repo_tag, args = '')
          run_git('clone', "#{repo(repo_tag).uri} #{args}")
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
          @command_host.execute_shell("git #{command} #{args}")
        end

        # Gets repo with a given tag from project
        # @return [Nanoci::Repo]
        def repo(repo_tag)
          raise "repo #{repo_tag} is not defined in the project #{@project.tag}" \
            unless @project.repos.key? repo_tag

          @project.repos[repo_tag]
        end
      end
    end
  end
end
