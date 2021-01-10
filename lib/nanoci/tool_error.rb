# frozen_string_literal: true

module Nanoci
  # Error class representing error while executing external tool
  class ToolError < StandardError
    attr_reader :cmd, :err, :code

    def initialize(cmd, code, err)
      msg = "command #{cmd} returned non-zero code #{code}\n#{err}"
      super(msg)
      @cmd = cmd
      @err = err
      @code = code
    end
  end
end
