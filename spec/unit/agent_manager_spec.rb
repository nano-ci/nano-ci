require 'spec_helper'

require 'nanoci/config'
require 'nanoci/agent_manager'

RSpec.describe Nanoci::AgentManager do
  it 'sets up local agents' do
    config = Nanoci::Config::new(
      'agents' => [
        'name' => 'Agent 1'
      ]
    )

    agent_manager = Nanoci::AgentManager.new(config, {})

    expect(agent_manager.agents).not_to be_nil
    expect(agent_manager.agents.length).to eq(1)
    expect(agent_manager.agents[0].name).to eq('Agent 1')
  end

  it 'pass common capabilities from config to agents' do
    config = Nanoci::Config::new(
      'agents' => [
        'name' => 'Agent 1'
      ],
      'capabilities' => ['test']
    )

    agent_manager = Nanoci::AgentManager.new(config, {})
    expect(agent_manager.agents[0].capabilities?(Set['test'])).to be true
  end

  it 'find agent with requested capabilities' do
    config = Nanoci::Config::new(
      'agents' => [
        'name' => 'Agent 1'
      ],
      'capabilities' => ['test']
    )

    agent_manager = Nanoci::AgentManager.new(config, {})
    expect(agent_manager.find_agent(Set['test'])).not_to be_nil
  end
end
