# frozen_string_literal: true

module Nanoci
  module Commands
    # Class that represents result of command execution
    class CommandOutput
      # @return [String]
      attr_reader :stdout
      attr_reader :exit_code, :stderr

      def initialize(exit_code, stdout, stderr)
        @exit_code = exit_code
        @stdout = stdout
        @stderr = stderr
      end
    end
  end
end
