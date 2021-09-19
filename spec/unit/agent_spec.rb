# frozen_string_literal: true

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
    expect(agent.tag).to eq(:test)
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
    build = double('build')
    agent = Nanoci::Agent.new(tag, caps)
    job_definition = Nanoci::Definition::JobDefinition.new(
      tag: 'test'
    )
    job = Nanoci::BuildJob.new(build, Nanoci::Job.new(job_definition))
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

  describe '#status=' do
    it 'call sets #status_timestamp to Time.now.utc' do
      agent = Nanoci::Agent.new(:test, test_cap: true)
      original_status_timestamp = agent.status_timestamp
      agent.status = Nanoci::AgentStatus::PENDING
      expect(agent.status_timestamp).not_to eq original_status_timestamp
      expect(agent.status_timestamp).to be_within(0.1).of(Time.now.utc)
    end
  end
end
