# frozen_string_literal: true

module Nanoci
  module Commands
    # Command to run basic shell command line.
    class Shell
      # Initializes new instance of [Nanoci::Commands::Shell]
      # @param host [Nanoci::CommandHost]
      def initialize(host)
        @host = host
      end

      def run(line)
        @host.execute_shell(line)
      end
    end
  end
end
