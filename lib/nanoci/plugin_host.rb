# frozen_string_literal: true

require 'pathname'

require_relative 'mixins/logger'

module Nanoci
  # Class [PluginHost] discovers, loads, and initializes plugins.
  class PluginHost
    include Nanoci::Mixins::Logger

    @plugin_entrypoints = {}

    class << self
      attr_reader :plugin_entrypoints

      def register_plugin(tag, klass)
        raise "duplicate plugin tag #{tag}" if plugin_entrypoints.key? tag

        plugin_entrypoints[tag] = klass
      end
    end

    # Initializes new instance of [PluginHost]
    # @param plugins_path [String] path to directory with plugins
    def initialize(plugins_path:)
      @plugins_path = plugins_path
      @plugins = {}

      discover_plugins(plugins_path: @plugins_path)
      init_plugins
    end

    # Returns plugin with given tag
    # @param tag [Symbol]
    # @return [Nanoci::Plugins::BasePlugin]
    def get_plugin(tag)
      @plugins.fetch(tag, nil)
    end

    private

    # Discovers and loads plugins at plugins_path
    # @param plugins_path [String]
    def discover_plugins(plugins_path:)
      log.info "loading plugins from #{plugins_path}..."
      Dir.glob(File.join(plugins_path, '*/*_plugin.rb')).each do |path|
        log.debug "loading plugin #{path}"
        load_plugin(path)
      end
    end

    def load_plugin(path)
      raise "cannot find plugin #{path}" unless File.exist? path

      plugin_file = File.expand_path(path)
      require_relative plugin_file
    end

    def init_plugins
      PluginHost.plugin_entrypoints.each do |tag, klass|
        log.debug { "initializing plugin #{klass}" }
        plugin = klass.new
        @plugins[tag] = plugin
        log.info { "plugin #{klass} is initialized" }
      end
    end
  end
end
