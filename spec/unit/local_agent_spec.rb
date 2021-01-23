# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/build'
require 'nanoci/local_agent'

RSpec.describe Nanoci::LocalAgent do
  it 'sets job state to RUNNING' do
    job = double('job')
    expect(job).to receive(:state=).with(Nanoci::Build::State::RUNNING).ordered
    expect(job).to receive(:state=).with(Nanoci::Build::State::COMPLETED).ordered

    allow(job).to receive(:tag).and_return('abc-1-def')
    job_definition = double('job_definition')
    allow(job_definition).to receive(:tasks).and_return([])
    allow(job).to receive(:definition).and_return(job_definition)

    config = double('config')
    allow(config).to receive(:name).and_return('test agent')
    allow(config).to receive(:capabilities).and_return('test' => nil)
    allow(config).to receive(:workdir).and_return('/abc')
    allow(config).to receive(:repo_cache).and_return('/def')
    local_agent = Nanoci::LocalAgent.new(config, {}, {})
    local_agent.run_job(nil, job)
  end
end
