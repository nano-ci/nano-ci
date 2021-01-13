# frozen_string_literal: true

require 'yaml'

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
        def initialize(argv = ARGV, config_path = nil)
          @instance = UCS.new(argv || [], config_path)
        end

        # Destroys an UCS instance
        def destroy
          @instance = nil
        end

        # parses ARGV into Hash
        # @param argv [Array<String>]
        # @return [Hash<Symbol, String>]
        def parse_argv(argv)
          argv.map do |item|
            raise "invalid option #{item} - does not start with --" unless item.start_with? '--'
            raise "invalid option #{item} - does not have = to split key and value" unless item.match(/.+=.+/)

            item.slice(2, item.length - 2).split('=')
          end.to_h.symbolize_keys
        end
      end

      # @return [Hash<Symbol, String>] argument vector AKA command line arguments
      attr_reader :argv

      # @return [Hash<Symbol, String>] environment variables
      attr_reader :env

      # @return [Hash<Symbol, String>] config
      attr_reader :config

      # Returns a config value in following order:
      # * ARGV
      # * environment variable
      # * config
      # @param key [Symbol] config key
      # @return [String] config value
      def get(key, default = nil)
        return @argv.fetch(key) if @argv.key?(key)
        return @env.fetch(key) if @env.key?(key)
        return @config.fetch(key) if !@config.nil? && @config.key?(key)
        return @override.fetch(key) if @override.key?(key)
        raise "missing config key '#{key}'" if default.nil?

        default
      end

      def override(key, value)
        @override[key] = value
      end

      private

      # Initializes new instance of [UCS]
      # @param argv [Array<String>] argument vector AKA command line arguments
      # @param config_path [String] path to config file
      def initialize(argv = ARGV, config_path = nil)
        @argv = UCS.parse_argv(argv).freeze
        @env = Hash[ENV].symbolize_keys.freeze

        config_path ||= @argv.fetch(:config, nil) || system_config_path

        @config = YAML.load_file(config_path).flatten_hash_value.freeze if File.exist?(config_path)

        @override = {}
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
