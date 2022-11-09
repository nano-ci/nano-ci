# frozen_string_literal: true

require 'pathname'

module Nanoci
  # Class [PluginHost] discovers, loads, and initializes plugins.
  class PluginHost
    @plugin_entrypoints = {}

    class << self
      attr_reader :plugin_entrypoints

      def register_plugin(tag, klass)
        raise "duplicate plugin tag #{tag}" if plugin_entrypoints.key? tag

        plugin_entrypoints[tag] = klass
      end
    end

    def initialize
      @plugins = {}

      # TODO: implement proper plugin discovery process
      load_plugin(:'command.git', 'lib/nanoci/plugins/git')
      load_plugin(:'command.ruby', 'lib/nanoci/plugins/ruby')
    end

    # Returns plugin with given tag
    # @param tag [Symbol]
    # @return [Nanoci::Plugins::CommandPlugin]
    def get_plugin(tag)
      @plugins.fetch(tag, nil)
    end

    def load_plugin(tag, plugin_descriptor)
      raise "cannot find plugin #{plugin_descriptor}" unless Dir.exist? plugin_descriptor

      pn = Pathname.new(plugin_descriptor)
      plugin_basename = pn.basename.to_s
      plugin_file = File.join(plugin_descriptor, "#{plugin_basename}_plugin")
      plugin_file = File.expand_path(plugin_file)
      require_relative plugin_file

      plugin_klass = PluginHost.plugin_entrypoints.fetch(tag, nil)

      raise "unknown plugin tag #{tag}" if plugin_klass.nil?

      @plugins[tag] = plugin_klass.new
    end
  end
end
