# frozen_string_literal: true

require 'trollop'

class Nanoci
  ##
  # Command line options for nano-ci
  class Options
    BANNER = <<-ABSTRACT
    nano-ci.

    Usage:
           nano-ci [options] <filenames>+
    where [options] are:
    ABSTRACT

    attr_accessor :config
    attr_accessor :project

    def initialize(opts)
      self.config = opts[:config]
      self.project = opts[:project]
    end

    def self.parse(options)
      opts = Trollop.options(options) do
        banner BANNER
        opt :config, 'Path to nano-ci config', type: :string
        opt :project, 'Path to project definition', type: :string
      end

      args = Options.new(opts)

      Trollop.die :project, 'is requried' if args.project.nil?

      args.project = File.expand_path(args.project) unless args.project.nil?

      args
    end
  end
end
