# frozen_string_literal: true

module Nanoci
  module Plugins
    # [Nanoci::Plugins::CommandPlugin] is the base class for plugins that
    # extends [Nanoci::CommandHost] with new commands.
    class CommandPlugin
      # Gets plugin tag
      # @return [Symbol]
      attr_reader :tag

      # Gets plugin semantic version
      # @return [String]
      attr_reader :version

      # Gets plugin module with extra commands
      # @return [Module]
      attr_reader :command_module

      # Augments command host with plugin commands
      # @param command_host [Nanoci::CommandHost]
      # @return [void]
      def augment_command_host(command_host)
        command_host.extend(command_module)
      end
    end
  end
end
