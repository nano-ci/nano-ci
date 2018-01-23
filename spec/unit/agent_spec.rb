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

    agent = Nanoci::Agent.new(config, Set[])
    expect(agent.name).to eq('test')
  end

  it 'reads capabilities from config' do
    config = Nanoci::Config::LocalAgentConfig.new(
      'name' => 'test',
      'capabilities' => ['test.cap']
    )

    agent = Nanoci::Agent.new(config, Set[])
    expect(agent.capabilities).to include Nanoci::AgentCapability.new('test.cap', nil)
  end

  it 'reads workdir from config' do
    config = Nanoci::Config::LocalAgentConfig.new(
      'name' => 'test',
      'capabilities' => ['test.cap'],
      'workdir' => '/abc'
    )

    agent = Nanoci::Agent.new(config, Set[])
    expect(agent.workdir).to eq '/abc'
  end

  it 'merges agent capabilities from config with common capabilities' do
    config = Nanoci::Config::LocalAgentConfig.new(
      'name' => 'test',
      'capabilities' => ['test.cap']
    )

    agent = Nanoci::Agent.new(config, Set[Nanoci::AgentCapability.new('test.common', nil)])
    expect(agent.capabilities).to include Nanoci::AgentCapability.new('test.common', nil)
  end

  it 'sets current job when it runs a job' do
    config = Nanoci::Config::LocalAgentConfig.new(
      'name' => 'test'
    )

    agent = Nanoci::Agent.new(config, Set[])
    job = Nanoci::BuildJob.new(Nanoci::Job.new('tag' => 'test'))
    agent.run_job(job)
    expect(agent.current_job).not_to be_nil
  end
end
