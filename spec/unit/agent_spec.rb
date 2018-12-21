require 'tmpdir'

require 'spec_helper'

require 'nanoci/agent'
require 'nanoci/build_job'
require 'nanoci/config'
require 'nanoci/job'

RSpec.describe Nanoci::Agent do
  it 'reads name from config' do
    tag = :test
    caps = {}
    agent = Nanoci::Agent.new(tag, caps)
    expect(agent.name).to eq('test')
  end

  it 'reads capabilities from config' do
    tag = :test
    caps = { 'test.cap' => nil }
    agent = Nanoci::Agent.new(tag, caps)
    expect(agent.capability?('test.cap')).to be true
  end

  it 'sets current job when it runs a job' do
    tag = :test
    caps = {}
    agent = Nanoci::Agent.new(tag, caps)
    job_definition = Nanoci::Definition::JobDefinition.new(
      tag: 'test'
    )
    job = Nanoci::BuildJob.new(Nanoci::Job.new(job_definition, nil))
    agent.run_job(nil, job)
    expect(agent.current_job).not_to be_nil
  end

  it 'capability returns nil is capability is missing' do
    tag = :test
    caps = {}
    agent = Nanoci::Agent.new(tag, caps)
    expect(agent.capability('test.cap')).to be nil
  end

  it 'capability returns true is capability value is nil' do
    tag = :test
    caps = { 'test.cap' => nil }
    agent = Nanoci::Agent.new(tag, caps)
    expect(agent.capability('test.cap')).to be true
  end

  it 'capability returns value of the capability' do
    tag = :test
    caps = { 'test.cap' => 'test.cap.value' }
    agent = Nanoci::Agent.new(tag, caps)
    expect(agent.capability('test.cap')).to eq 'test.cap.value'
  end
end
