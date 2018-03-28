# frozen_string_literal: true

class Nanoci
  ##
  # Error class representing test execution error
  class TestError < StandardError
    attr_reader :failed_tests

    def initialize(failed_tests)
      @failed_tests = failed_tests
      msg = "failed tests:\n" + @failed_tests.map { |t| "  #{t.tag}" }.join("\n")
      super(msg)
    end
  end
end
