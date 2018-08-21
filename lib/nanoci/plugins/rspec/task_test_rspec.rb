# frozen_string_literal: true

require 'json'

require 'nanoci/tasks/task_test'
require 'nanoci/test'

class Nanoci
  class Plugins
    class RSpec
      # RSpec run task class
      class TaskTestRSpec < Nanoci::Tasks::TaskTest
        provides 'test-rspec'

        RSPEC_CAP = 'tools.rspec'

        @status_mapping = {
          'passed' => Test::State::PASS,
          'failed' => Test::State::FAIL
        }

        class << self
          attr_reader :status_mapping
        end

        attr_reader :action

        def initialize(hash = {})
          super(hash)
          @action = hash['action'] || 'run_tool'
          @options = hash['options'] || {}
          @result_file = hash['result_file']

          raise 'result_file must be specified if action is "read_file"' if \
            @action == 'read_file' && @result_file.nil?
        end

        def required_agent_capabilities(project)
          requirements = super(project)
          requirements << RSPEC_CAP if @action == 'run_tool'
          requirements
        end

        def execute_imp(build, env)
          case @action
          when 'run_tool'
            execute_run_tool(build, env)
          when 'read_file'
            execute_read_file(build, env)
          end
        end

        private

        def execute_run_tool(build, env)
          opts = sanitize_opts(@options.clone, env)
          cmd = opts.map { |k, v| (k + ' ' + v).strip }.join(' ')
          rspec(env[RSPEC_CAP], cmd, stdout: build.output, stderr: build.output)
          results = read_results(opts['--out'])
          handle_results(results, build)
        end

        def sanitize_opts(opts, env)
          opts['--format'] = 'json'
          opts['--out'] = File.join(env['build_data_dir'], 'rspec_output.json')
          opts
        end

        def execute_read_file(build, env); end

        def rspec(rspec_path, cmd, opts = {})
          opts[:throw_non_zero_exit_code] = false
          ToolProcess.run("\"#{rspec_path}\" #{cmd}", opts).wait
        end

        def read_results(path)
          data = File.read(path)
          json = JSON.parse(data)
          json['examples'].map do |example|
            Test.new(
              example['full_description'],
              TaskTestRSpec.status_mapping[example['status']]
            )
          end
        end
      end
    end
  end
end
