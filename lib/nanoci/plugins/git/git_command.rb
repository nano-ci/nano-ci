# frozen_string_literal: true

module Nanoci
  module Plugins
    module Git
      # Class [GitCommand] implements git commands.
      class GitCommand
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
