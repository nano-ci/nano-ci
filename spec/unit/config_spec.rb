require 'spec_helper'

require 'nanoci/config'

RSpec.describe Nanoci::Config do
  it 'property local_agents returns nil is the src value is absent' do
    config = Nanoci::Config.new({})
    expect(config.local_agents).to be_nil
  end

  it 'property local_agents returns LocalAgentsConfig if the src value is present' do
    config = Nanoci::Config.new('local_agents' => {})
    expect(config.local_agents).to be_a(Nanoci::Config::LocalAgentsConfig)
  end

  it 'property job_scheduler_interval returns default value 5 if the src value is absent' do
    config = Nanoci::Config.new({})
    expect(config.job_scheduler_interval).to eq 5
  end

  it 'property job_scheduler_interval returns the src value' do
    config = Nanoci::Config.new('job_scheduler_interval' => 10)
    expect(config.job_scheduler_interval).to eq 10
  end

  it 'property plugins_path returns nil if the src value is absent' do
    config = Nanoci::Config.new({})
    expect(config.plugins_path).to be_nil
  end

  it 'property plugins_path returns the src value' do
    config = Nanoci::Config.new('plugins_path' => '/abc')
    expect(config.plugins_path).to eq '/abc'
  end
end

RSpec.describe Nanoci::Config::LocalAgentsConfig do
  it 'property capabilities returns empty set if the src value is absent' do
    config = Nanoci::Config::LocalAgentsConfig.new({})
    expect(config.capabilities).to be_a(Hash)
    expect(config.capabilities.length).to eq 0
  end

  it 'property capabilities returns set with values from src' do
    config = Nanoci::Config::LocalAgentsConfig.new('capabilities' => ['abc', {'def' => 'ghi'}])
    expect(config.capabilities).to be_a(Hash)
    expect(config.capabilities.length).to eq 2
    expect(config.capabilities.key?('abc')).to be true
    expect(config.capabilities['abc']).to be nil
    expect(config.capabilities.key?('def')).to be true
    expect(config.capabilities['def']).to eq 'ghi'
  end

  it 'property agents returns empty array if the src value is absent' do
    config = Nanoci::Config::LocalAgentsConfig.new({})
    expect(config.agents).to be_a(Array)
    expect(config.agents.length).to eq 0
  end

  it 'property agents returns array of LocalAgentsConfig if the src value is present' do
    config = Nanoci::Config::LocalAgentsConfig.new('agents' => [{}])
    expect(config.agents).to be_an(Array)
    expect(config.agents.length).to eq 1
    expect(config.agents[0]).to be_an(Nanoci::Config::LocalAgentConfig)
  end
end

RSpec.describe Nanoci::Config::LocalAgentConfig do
  it 'property capabilities returns an empty set if the src value is absent' do
    config = Nanoci::Config::LocalAgentConfig.new({})
    expect(config.capabilities).to be_a(Hash)
    expect(config.capabilities.length).to eq 0
  end

  it 'property workdir returns a value from src' do
    config = Nanoci::Config::LocalAgentConfig.new('workdir' => '/abc')
    expect(config.workdir).to eq '/abc'
  end

  it 'property capabilities returns a set with the src values' do
    config = Nanoci::Config::LocalAgentConfig.new('capabilities' => ['abc', { 'def' => 'ghi' }])
    expect(config.capabilities).to be_a(Hash)
    expect(config.capabilities.key?('abc')).to be true
    expect(config.capabilities['abc']).to eq nil
    expect(config.capabilities.key?('def')).to be true
    expect(config.capabilities['def']).to eq 'ghi'
  end

  it 'reads repo-cache from src' do
    config = Nanoci::Config::LocalAgentConfig.new('repo-cache' => 'abc')
    expect(config.repo_cache).to eq 'abc'
  end
end
