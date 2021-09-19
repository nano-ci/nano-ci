# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'bundler/setup'
require 'logging'
require 'rspec/logging_helper'

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

  include RSpec::LoggingHelper
  config.capture_log_messages
end

SimpleCov.configure do
  add_filter 'spec'
end
