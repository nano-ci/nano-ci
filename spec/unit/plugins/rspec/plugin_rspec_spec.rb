# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/plugins/rspec/plugin_rspec'
require 'nanoci/plugins/rspec/task_test_rspec'

RSpec.describe 'nano-ci plugin rspec' do
  it 'registers task:test-rspec' do
    expect(Nanoci.resources.get('task:test-rspec')).to eq Nanoci::Plugins::RSpec::TaskTestRSpec
  end
end
