require 'spec_helper'

require 'nanoci/build_job'
require 'nanoci/job'
require 'nanoci/task'

RSpec.describe Nanoci::BuildJob do
  it 'saves passed job to field' do
    job_def = Nanoci::Definition::JobDefinition.new(
      tag: 'test'
    )
    job = Nanoci::Job.new(job_def, nil)
    build_job = Nanoci::BuildJob.new(job)
    expect(build_job.definition).to eq(job)
  end

  it 'returns required agent capabilities from job definition' do
    Nanoci.resources.clean

    class TestTask < Nanoci::Task
      provides 'test-task'
      def required_agent_capabilities
        Set['test.cap']
      end
    end

    job_def = Nanoci::Definition::JobDefinition.new(
      tag: 'test',
      tasks: [
        type: 'test-task'
      ]
    )

    job = Nanoci::Job.new(job_def, nil)
    build_job = Nanoci::BuildJob.new(job)
    expect(build_job.required_agent_capabilities).to eq(job.required_agent_capabilities)
  end
end
