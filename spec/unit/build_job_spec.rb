require 'spec_helper'

require 'nanoci/build_job'
require 'nanoci/job'
require 'nanoci/task'

class TestTask < Nanoci::Task
  def required_agent_capabilities(_)
    Set['test.cap']
  end
end

RSpec.describe Nanoci::BuildJob do
  it 'saves passed job to field' do
    job = Nanoci::Job.new('tag' => 'test')
    build_job = Nanoci::BuildJob.new(job)
    expect(build_job.definition).to eq(job)
  end

  it 'returns required agent capabilities from job definition' do
    job = Nanoci::Job.new('tag' => 'test')
    job.tasks = [TestTask.new]
    build_job = Nanoci::BuildJob.new(job)
    expect(build_job.required_agent_capabilities).to eq(job.required_agent_capabilities)
  end
end
