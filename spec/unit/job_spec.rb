# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/definition/job_definition'
require 'nanoci/job'
require 'nanoci/task'

RSpec.describe Nanoci::Job do
  before(:all) do
    Nanoci.resources.push

    class TestTask1 < Nanoci::Task
      provides 'test-task1'

      def required_agent_capabilities
        Set['abc']
      end
    end

    class TestTask2 < Nanoci::Task
      provides 'test-task2'

      def required_agent_capabilities
        Set['def']
      end
    end
  end

  after(:all) do
    Nanoci.resources.pop
  end

  it 'reads tag from definition' do
    definition = Nanoci::Definition::JobDefinition.new(
      tag: 'build-job'
    )
    job = Nanoci::Job.new(definition, nil)
    expect(job.tag).to eq :'build-job'
  end

  it 'required_agent_capabilities returns a Set' do
    definition = Nanoci::Definition::JobDefinition.new(
      tag: 'build-job',
      tasks: [{
        type: 'test-task1'
      }]
    )

    job = Nanoci::Job.new(definition, nil)

    expect(job.required_agent_capabilities).to be_a(Set)
  end

  it 'merges tasks required agent capabilities' do
    definition = Nanoci::Definition::JobDefinition.new(
      tag: 'build-job',
      tasks: [{ type: 'test-task1' }, { type: 'test-task2' }]
    )

    job = Nanoci::Job.new(definition, nil)

    expect(job.required_agent_capabilities).to include 'abc'
    expect(job.required_agent_capabilities).to include 'def'
  end
end
