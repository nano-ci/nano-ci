# frozen_string_literal: true

require 'nanoci/plugin'

module Nanoci
  ##
  # nano-ci plugin loader
  class PluginLoader
    def self.load(plugins_path)
      Dir.foreach(plugins_path) do |plugin_dir|
        next if File.file? plugin_dir
        next if plugin_dir == '.'
        next if plugin_dir == '..'

        plugin = File.join(plugins_path, plugin_dir, "plugin_#{plugin_dir}")
        require plugin
      end

      Plugin.plugins.each(&:new)
    end
  end
end
