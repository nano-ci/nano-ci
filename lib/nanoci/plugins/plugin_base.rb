# frozen_string_literal: true

module Nanoci
  module Plugins
    # [Nanoci::Plugins::PluginBase] is the base class for nano-ci plugins
    class PluginBase
      # Gets plugin tag
      # @return [Symbol]
      attr_reader :tag

      # Gets plugin semantic version
      # @return [String]
      attr_reader :version

      # Augments passed [ExtensionPoint] with entry points to plugin
      # @param extension_point [Nanoci::Plugins::ExtensionPoint]
      # @note plugins should override this method to add entry points
      def augment(extension_point)
        extension_point
      end
    end
  end
end
