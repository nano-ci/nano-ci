# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
end

require 'bundler/setup'
require 'rspec'

if ENV['RUBY_LSP_TEST_RUNNER']
  # Ruby LSP's default reporters are for minitest/test-unit. For RSpec suites,
  # notify the test runner explicitly so VS Code can finalize test execution.
  at_exit do
    if defined?(RubyLsp::LspReporter)
      begin
        RubyLsp::LspReporter.instance.shutdown
      rescue StandardError => e
        warn "[nano-ci][ruby-lsp] shutdown raised #{e.class}: #{e.message}"
      end
    end
  end
end
# require 'rspec/logging_helper'

require 'nanoci'

require_relative 'helpers/capture_stderr'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # include RSpec::LoggingHelper
  # config.capture_log_messages
end
