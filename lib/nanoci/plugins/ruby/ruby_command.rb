# frozen_string_literal: true

require_relative 'rspec_command'

module Nanoci
  module Plugins
    module Ruby
      # [RubyCommand] is a command that enables ruby-related actions, e.g., rake, gem, bundle, etc.
      class RubyCommand
        # Initializes new instance of [RubyCommand]
        # @param command_host [Nanoci::CommandHost] command host
        # @param project [Nanoci::Core::Project] project
        def initialize(command_host, project)
          @command_host = command_host
          @project = project
        end

        def rspec
          RSpecCommand.new(@command_host, @project)
        end
      end
    end
  end
end
