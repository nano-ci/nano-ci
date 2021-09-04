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
    end
  end
end
