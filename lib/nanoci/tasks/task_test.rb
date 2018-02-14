require 'nanoci/task'
require 'nanoci/test_error'

class Nanoci
  class Tasks
    class TaskTest < Task
      def handle_results(results, build)
        build.tests.push(*results)
        failed_tests = results.select { |t| t.state == Test::State::FAIL}
        raise TestError.new(failed_tests) if failed_tests.any?
      end
    end
  end
end
