# frozen_string_literal: true

require 'json'
require 'logging'

require 'nanoci/common_vars'
require 'nanoci/plugins/rspec/task_test_rspec_definition'
require 'nanoci/tasks/task_test'
require 'nanoci/test'

class Nanoci
  class Plugins
    class RSpec
      # RSpec run task class
      class TaskTestRSpec < Nanoci::Tasks::TaskTest
        provides 'test-rspec'

        RSPEC_CAP = :'tools.rspec'

        @status_mapping = {
          'passed' => Test::State::PASS,
          'failed' => Test::State::FAIL
        }

        class << self
          attr_reader :status_mapping
        end

        # task action
        # @return [Symbol]
        def action
          @definition.action
        end

        # rspec options
        # @return [Hash]
        def options
          @definition.options
        end

        # result file to read
        # @return [String]
        def result_file
          @definition.result_file
        end

        def initialize(definition, project)
          @log = Logging.logger[self]
          definition = Nanoci::Definition::TaskTestRSpecDefinition.new(definition.params)
          super(definition, project)
        end

        def required_agent_capabilities
          requirements = super
          requirements << RSPEC_CAP if action == 'run_tool'
          requirements
        end

        def execute_imp(build, env)
          case action
          when :run_tool
            execute_run_tool(build, env)
          when :read_file
            execute_read_file(build, env)
          else
            @log.error("unknown action #{action}")
          end
        end

        private

        def execute_run_tool(build, env)
          opts = sanitize_opts(options.clone, env)
          cmd = opts.map { |k, v| (k + ' ' + v).strip }.join(' ')
          rspec(env[RSPEC_CAP], cmd, chdir: env[CommonVars::WORKDIR], stdout: build.output, stderr: build.output)
          results = read_results(opts['--out'])
          handle_results(results, build)
        end

        def sanitize_opts(opts, env)
          opts['--format'] = 'json'
          opts['--out'] = File.join(env[CommonVars::BUILD_DATA_DIR], 'rspec_output.json')
          opts
        end

        def execute_read_file(build, env); end

        def rspec(rspec_path, cmd, opts = {})
          ToolProcess.run("\"#{rspec_path}\" #{cmd}", opts).wait
        end

        def read_results(path)
          return [] unless File.exist? path
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
