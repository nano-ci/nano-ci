require 'spec_helper'

require 'nanoci/build'
require 'nanoci/local_agent'

RSpec.describe Nanoci::LocalAgent do
  it 'sets job state to RUNNING' do
    job = double('job')
    allow(job).to receive(:state=) do |s|
      expect(s).to eq Nanoci::Build::State::RUNNING
    end

    config = double('config')
    allow(config).to receive(:name).and_return('test agent')
    allow(config).to receive(:capabilities).and_return(Set['test'])
    local_agent = Nanoci::LocalAgent.new(config, Set[])
    local_agent.run_job(job)
  end
end
