# frozen_string_literal: true

require 'spec_helper'

require 'set'

require 'nanoci/agent_engine'
require 'nanoci/event'

RSpec::Matchers.define :a_hash_with_keys do |x|
  match do |actual|
    Set.new(actual.keys) >= Set.new(x)
  end
end

RSpec.describe Nanoci::AgentEngine do
  before(:example) do
    ucs = Nanoci::Config::UCS.initialize(nil, nil)
    ucs.override(Nanoci::Config::AgentConfig::AGENT_MANAGER_SERVICE_URI, '')
    ucs.override(Nanoci::Config::AgentConfig::AGENT_TAG, :test)
    ucs.override(Nanoci::Config::AgentConfig::WORKDIR, :test)
  end

  after(:example) do
    Nanoci::Config::UCS.destroy
  end

  it 'subscribes to agent events' do
    event_engine = double('event_engine')
    expect(event_engine).to receive(:register).with(a_hash_with_keys([
                                                                       Nanoci::Events::GET_NEXT_JOB,
                                                                       Nanoci::Events::REPORT_JOB_STATE,
                                                                       Nanoci::Events::REPORT_STATUS
                                                                     ]))
    Nanoci::AgentEngine.new(event_engine)
  end
end
