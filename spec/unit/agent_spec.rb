require 'tmpdir'

require 'spec_helper'

require 'nanoci/agent'
require 'nanoci/build_job'
require 'nanoci/config'
require 'nanoci/job'

RSpec.describe Nanoci::Agent do
  it 'reads name from config' do
    config = Nanoci::Config::LocalAgentConfig.new(
      'name' => 'test'
    )

    agent = Nanoci::Agent.new(config, {}, {})
    expect(agent.name).to eq('test')
  end

  it 'reads capabilities from config' do
    config = Nanoci::Config::LocalAgentConfig.new(
      'name' => 'test',
      'capabilities' => ['test.cap']
    )

    agent = Nanoci::Agent.new(config, {}, {})
    expect(agent.capability?('test.cap')).to be true
  end

  it 'reads workdir from config' do
    config = Nanoci::Config::LocalAgentConfig.new(
      'name' => 'test',
      'capabilities' => ['test.cap'],
      'workdir' => '/abc'
    )

    agent = Nanoci::Agent.new(config, {}, {})
    expect(agent.workdir).to eq '/abc'
  end

  it 'merges agent capabilities from config with common capabilities' do
    config = Nanoci::Config::LocalAgentConfig.new(
      'name' => 'test',
      'capabilities' => ['test.cap']
    )

    agent = Nanoci::Agent.new(config, { 'test.common' => nil }, {})
    expect(agent.capability?('test.common')).to be true
  end

  it 'sets current job when it runs a job' do
    config = Nanoci::Config::LocalAgentConfig.new(
      'name' => 'test'
    )

    agent = Nanoci::Agent.new(config, {}, {})
    job = Nanoci::BuildJob.new(Nanoci::Job.new('tag' => 'test'))
    agent.run_job(nil, job)
    expect(agent.current_job).not_to be_nil
  end

  it 'capability returns nil is capability is missing' do
    config = Nanoci::Config::LocalAgentConfig.new(
      'name' => 'test'
    )
    agent = Nanoci::Agent.new(config, {}, {})
    expect(agent.capability('test.cap')).to be nil
  end

  it 'capability returns true is capability value is nil' do
    config = Nanoci::Config::LocalAgentConfig.new(
      'name' => 'test',
      'capabilities' => [{ 'test.cap' => nil }]
    )
    agent = Nanoci::Agent.new(config, {}, {})
    expect(agent.capability('test.cap')).to be true
  end

  it 'capability returns value of the capability' do
    config = Nanoci::Config::LocalAgentConfig.new(
      'name' => 'test',
      'capabilities' => [{ 'test.cap' => 'test.cap.value' }]
    )
    agent = Nanoci::Agent.new(config, {}, {})
    expect(agent.capability('test.cap')).to eq 'test.cap.value'
  end

  it 'executes task in workdir' do
    dir = Dir.mktmpdir
    config = Nanoci::Config::LocalAgentConfig.new(
      'name' => 'test',
      'workdir' => dir
    )
    agent = Nanoci::Agent.new(config, {}, {})
    task = double('task')
    allow(task).to receive(:execute) {
      expect(Dir.pwd).to eq(dir)
    }
    allow(task).to receive(:type).and_return('mock_task')
    build = double('build')
    allow(build).to receive(:tag).and_return('abc-1')
    agent.execute_task(build, 'abc', task)
  end
end
