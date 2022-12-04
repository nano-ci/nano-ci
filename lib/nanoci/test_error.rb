# frozen_string_literal: true

module Nanoci
  ##
  # Error class representing test execution error
  class TestError < StandardError
    attr_reader :failed_tests

    def initialize(failed_tests)
      @failed_tests = failed_tests
      error_lines = @failed_tests.map { |t| "  #{t.tag}" }.join("\n")
      msg = "failed tests:\n#{error_lines}"
      super(msg)
    end
  end
end
