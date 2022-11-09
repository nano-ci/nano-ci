# frozen_string_literal: true

module Nanoci
  module Plugins
    module Ruby
      # [RSpecCommand] enables rspec actions
      class RSpecCommand
        # Initializes new instance of [RSpecCommand]
        # @param command_host [Nanoci::CommandHost] command host
        # @param project [Nanoci::Core::Project]
        def initialize(command_host, project)
          @command_host = command_host
          @project = project
        end

        # Runs spec in current directory
        # @param filter [String] Optional examples filter in format supported by rspec
        # @param opts [String] Optional extra command line to pass to rspec
        def run(filter = nil, opts = nil)
          @command_host.execute_shell(format_command(filter, opts))
        end

        private

        def format_command(filter, opts)
          ['rspec', filter, opts].reject { |v| v.nil? || v.empty? }.join(' ')
        end
      end
    end
  end
end
