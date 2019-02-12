# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/config/ucs'
require 'nanoci/agent_manager'

RSpec.describe Nanoci::AgentManager do
  it 'find agent with requested capabilities' do
    agent_manager = Nanoci::AgentManager.new
    agent = double('agent')
    allow(agent).to receive(:tag).and_return(:agent)
    allow(agent).to receive(:capabilities).and_return(Set[:test])
    allow(agent).to receive(:capabilities?).and_return(true)
    allow(agent).to receive(:status).and_return(Nanoci::AgentStatus::IDLE)
    agent_manager.add_agent(agent)
    expect(agent_manager.find_agent(Set[:test])).not_to be_nil
  end

  describe 'using #timedout_agents' do
    it 'returns pending agents with status timestamp older than timeout' do
      agent_manager = Nanoci::AgentManager.new
      agent = double('agent')
      allow(agent).to receive(:tag).and_return(:agent)
      allow(agent).to receive(:capabilities?).and_return(true)
      allow(agent).to receive(:status).and_return(Nanoci::AgentStatus::PENDING)
      allow(agent).to receive(:status_timestamp).and_return(Time.now - 100)
      agent_manager.add_agent(agent)

      expect(agent_manager.timedout_agents(10)).to include(agent)
    end
  end
end
