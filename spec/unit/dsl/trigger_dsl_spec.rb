# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/trigger'
require 'nanoci/dsl/trigger_dsl'

RSpec.describe Nanoci::DSL::TriggerDSL do
  it 'reads tag from DSL' do
    dsl = Nanoci::DSL::TriggerDSL.new(:poll, :project)
    # rubocop:disable Lint/EmptyBlock
    dsl.instance_eval do
    end
    # rubocop:enable Lint/EmptyBlock
    trigger = dsl.build
    expect(trigger.tag).to eq :poll
  end
end
