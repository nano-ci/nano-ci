# frozen_string_literal: true

require 'pathname'

module Nanoci
  # Class [PluginHost] discovers, loads, and initializes plugins.
  class PluginHost
    class << self
      def register_plugin(tag, klass)
        raise "duplicate plugin tag #{tag}" if plugin_entrypoints.key? tag

        plugin_entrypoints[tag] = klass
      end

      private

      def plugin_entrypoints
        @plugin_entrypoints ||= {}
      end
    end

    def initialize
      @plugins = {}

      # TODO: implement proper plugin discovery process
      load_plugin(:'command.git', 'lib/nanoci/plugins/git')
    end

    def load_plugin(tag, plugin_descriptor)
      raise "cannot find plugin #{plugin_descriptor}" unless Dir.exist? plugin_descriptor

      pn = Pathname.new(plugin_descriptor)
      plugin_basename = pn.basename.to_s
      plugin_file = File.join(plugin_descriptor, "#{plugin_basename}_plugin")
      plugin_file = File.expand_path(plugin_file)
      require_relative plugin_file

      raise "unknown plugin tag #{tag}" unless PluginHost.plugin_entrypoints.key? tag

      plugin_class = @@plugin_entrypoints.fetch(tag)
      plugin_object = plugin_class.new
      @plugins[tag] = plugin_object
    end
  end
end
