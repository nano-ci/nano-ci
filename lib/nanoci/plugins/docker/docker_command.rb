# frozen_string_literal: true

require 'json'
require 'set'
require 'tempfile'

module Nanoci
  module Plugins
    module Docker
      # Class [DockerCommand] implements docker commands.
      class DockerCommand
        @commands = Set.new(%i[
                              run
                              exec
                            ]).freeze

        class << self
          attr_reader :commands
        end
        # Initializes new instance of [GitCommand]
        # @param command_host [Nanoci::CommandHost]
        # @param project [Nanoci::Project]
        # @param repo [Nanoci::Core::Repo]
        def initialize(command_host, project)
          @command_host = command_host
          @project = project
          @image = nil
        end

        def image(image_name)
          @image = image_name
          self
        end

        def run(options: nil, command: nil)
          raise 'missing image name' if @image.nil?

          cmd = ['run']
          cmd.push(options) unless options.nil?
          cmd.push(@image)
          run_command(cmd.join(' '), command)
        end

        def rm(container_name)
          run_command('rm', container_name)
        end

        def ps
          res = run_command('ps', '--format=json --all')
          res.stdout.split("\n").map { |s| JSON.parse(s) }
        end

        def method_missing(method_name, *args, &_block)
          return unless self.class.commands.include?(method_name.to_sym)

          command_name = method_name

          if args.empty?
            run_command(command_name)
          else
            run_command(command_name, args[0])
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          self.class.commands.include?(method_name.to_sym) || super
        end

        private

        def run_command(command, args = '')
          @command_host.execute_shell("docker #{command} #{args}", env: env)
        end
      end
    end
  end
end
