require 'trollop'

class Nanoci
  ##
  # Command line options for nano-ci
  class Options
    BANNER = <<-EOS
    nano-ci.

    Usage:
           nano-ci [options] <filenames>+
    where [options] are:
    EOS
             .freeze

    attr_accessor :dryrun
    attr_accessor :project
    attr_accessor :plugins_path

    def initialize(opts)
      self.dryrun = opts[:dry_run]
      self.project = opts[:project]
      self.plugins_path = File.expand_path opts[:plugins_path]
    end

    def self.parse(options)
      opts = Trollop.options(options) do
        banner BANNER
        opt :dry_run, 'Run dry-run'
        opt :project, 'Path to project definition', :type => :string
        opt :plugins_path, 'Path to plugins', :type => :string
      end

      args = Options.new(opts)

      Trollop.die :project, 'is requried' if args.dryrun && args.project.nil?

      args.project = File.expand_path(args.project) unless args.project.nil?

      args
    end
  end
end
