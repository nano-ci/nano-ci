# frozen_string_literal: true

require 'precursor'

require 'nanoci/config/agent_config'
require 'nanoci/config/service_config'
require 'nanoci/config/system_config'
require 'nanoci/utils/hash_utils'

module Nanoci
  module Config
    # UCS is an unified config system
    class UCS
      include AgentConfig
      include ServiceConfig
      include SystemConfig

      class << self
        # @return [UCS] an instance of UCS
        def instance
          raise 'UCS is not initialized' if @instance.nil?

          @instance
        end

        # Initializes an UCS
        # @return [UCS]
        def initialize(argv = ARGV)
          @instance = UCS.new(argv || [])
        end

        # Destroys an UCS instance
        def destroy
          @config_root = nil
        end
      end

      # Returns a config value in following order:
      # * ARGV
      # * environment variable
      # * config
      # @param key [Symbol] config key
      # @return [String] config value
      def get(key)
        @config_root[key]
      end

      def override(key, value)
        @override_vault.override(key, value)
      end

      private

      # Initializes new instance of [UCS]
      # @param argv [Array<String>] argument vector AKA command line arguments
      # @param config_path [String] path to config file
      def initialize(argv = ARGV)
        @config_root = Precursor.create do |builder|
          @override_vault = Precursor::OverrideVault.new

          builder.vault @override_vault
          builder.vault(setup_argv_vault(argv))
          builder.vault(Precursor::EnvVault.new)
          builder.vault(Precursor::YamlFileVault.new('${config}'))

          setup_defaults(builder)
        end
      end

      def setup_argv_vault(argv)
        Precursor::ArgvVault.new(argv) do |argv_builder|
          argv_builder.key :config do |kv|
            kv.long '--config PATH'
            kv.description 'Path to config file'
          end

          argv_builder.key :project do |kv|
            kv.long '--project PROJECT'
            kv.description 'Path to project file'
          end
        end
      end

      def setup_defaults(builder)
        builder.key :config do |kb|
          kb.default system_config_path
        end

        builder.key :'plugins-path' do |kb|
          kb.default 'lib/nanoci/plugins'
        end
      end

      def destroy
        @argv = nil
        @env = nil
        @config = nil
      end

      # Expands references to environment variables
      # @param name [String]
      # @return [String]
      def expand_env(name)
        return name unless name.is_a? String

        match = /\$\{([^}]*)\}/.match(name)
        if match.nil? || ENV[match[1]].nil?
          name
        else
          name.sub("${#{match[1]}}", ENV[match[1]])
        end
      end

      # @return [String] configuration path
      def system_config_path
        if Gem.win_platform?
          expand_env(File.join('${ProgramData}', 'nano-ci', 'config.yml'))
        else
          '/etc/nano-ci/config.yml'
        end
      end
    end
  end
end
