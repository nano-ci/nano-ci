require 'spec_helper'

require 'nanoci/job'

RSpec.describe Nanoci::Job do
  it 'required_agent_capabilities returns a Set' do
    task1 = double('task1')
    allow(task1).to receive(:required_agent_capabilities).and_return(Set['abc'])

    job = Nanoci::Job.new(double('project'))
    job.tasks = [task1]

    expect(job.required_agent_capabilities).to be_a(Set)
  end

  it 'merges tasks required agent capabilities' do
    task1 = double('task1')
    allow(task1).to receive(:required_agent_capabilities).and_return(Set['abc'])

    task2 = double('task2')
    allow(task2).to receive(:required_agent_capabilities).and_return(Set['def'])

    job = Nanoci::Job.new(double('project'))
    job.tasks = [task1, task2]

    expect(job.required_agent_capabilities).to include 'abc'
    expect(job.required_agent_capabilities).to include 'def'
  end
end
