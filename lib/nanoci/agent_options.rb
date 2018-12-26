# frozen_string_literal: true

require 'optimist'

module Nanoci
  # Command line options for nano-ci agent
  class AgentOptions
    BANNER = <<-ABSTRACT
    nano-ci.

    Usage:
            nano-ci [options] <filenames>+
    where [options] are:
    ABSTRACT

    attr_reader :config

    def initialize(opts)
      @config = opts[:config]
    end

    # Parses command line arguments
    # @param cli_args [Array<String>]
    # @return [AgentOptions]
    def self.parse(cli_args)
      opts = Optimist.options(cli_args) do
        banner BANNER
        opt :config, 'Path to nano-ci agent config', type: :string
      end

      args = AgentOptions.new(opts)

      Optimist.die :config, 'is required' if args.config.nil?

      args
    end
  end
end
