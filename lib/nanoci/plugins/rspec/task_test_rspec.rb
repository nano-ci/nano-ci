# frozen_string_literal: true

require 'json'
require 'logging'

require 'nanoci/plugins/rspec/task_test_rspec_definition'
require 'nanoci/tasks/task_test'
require 'nanoci/test'

module Nanoci
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

        def initialize(definition)
          @log = Logging.logger[self]
          definition = Nanoci::Plugins::RSpec::TaskTestRSpecDefinition.new(definition.params)
          super(definition)
        end

        def required_agent_capabilities(build)
          requirements = super(build)
          requirements << RSPEC_CAP if action == 'run_tool'
          requirements
        end

        def execute_imp(build, workdir)
          case action
          when :run_tool
            execute_run_tool(build, workdir)
          when :read_file
            execute_read_file(build, workdir)
          else
            @log.error("unknown action #{action}")
          end
        end

        private

        def execute_run_tool(build, workdir)
          output = File.join(workdir, 'rspec_output.json')
          opts = {
            '--format' => 'json',
            '--out' => output
          }
          cmd = opts.map { |k, v| "#{k} #{v}".strip }.join(' ')
          agent_capabilities = Config::UCS.instance.agent_capabilities
          rspec(agent_capabilities[RSPEC_CAP], cmd, chdir: workdir, stdout: build.output, stderr: build.output)
          results = read_results(output)
          handle_results(results, build)
        end

        def execute_read_file(build, workdir); end

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
