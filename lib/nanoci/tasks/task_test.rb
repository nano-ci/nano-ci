# frozen_string_literal: true

require 'nanoci/task'
require 'nanoci/test_error'

class Nanoci
  class Tasks
    # Base class for test tool task
    # It is supposed to be a base class for plugin tasks
    class TaskTest < Task
      def handle_results(results, build)
        build.tests.push(*results)
        failed_tests = results.select { |t| t.state == Test::State::FAIL }
        raise TestError, failed_tests if failed_tests.any?
      end
    end
  end
end
