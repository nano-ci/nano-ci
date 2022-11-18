# frozen_string_literal: true

module Nanoci
  module Plugins
    # [ExtensionPoint] is an interface between nano-ci and plugin
    # Plugin hooks up entry points to extension point.
    # nano-ci uses extension point to call into plugin
    class ExtensionPoint
      def initialize
        @commands = {}
      end

      def add_command(command, proc)
        validate_command(command, proc)

        raise "duplicate command #{command}" if @commands.key? command

        @commands[command] = proc
      end

      # Find command by tag
      # @param command [Symbol]
      # @return [Proc|Nil]
      def find_command(command)
        @commands.fetch(command, nil)
      end

      # Returns true if command is available at the extension point
      # @param command [Symbol]
      # @return [Boolean]
      def command?(command)
        @commands.key? command
      end

      private

      # Validates plugin command and proc
      # @param command [Symbol]
      # @param proc [Proc]
      def validate_command(command, proc)
        raise "command tag #{command} is not a Symbol" unless command.is_a? Symbol
        raise "proc of command #{command} is not a Proc" unless proc.is_a? Proc
        raise "arity of command #{command} proc is less then 2" unless proc.arity >= 2
      end
    end
  end
end
