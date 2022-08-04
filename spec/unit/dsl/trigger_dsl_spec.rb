# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/trigger'
require 'nanoci/dsl/trigger_dsl'

RSpec.describe Nanoci::DSL::TriggerDSL do
  before(:each) do
    @component_factory = double(:component_factory)
    @trigger_factory = double(:component_factory)
    allow(@component_factory).to receive(:triggers).and_return(@trigger_factory)
    allow(@trigger_factory).to receive(:build) do |tag, type, _|
      Nanoci::Core::Trigger.new(tag: tag, type: type)
    end
  end

  it 'reads tag from DSL' do
    dsl = Nanoci::DSL::TriggerDSL.new(@component_factory, :poll)
    dsl.instance_eval do
      schedule 42
    end
    trigger = dsl.build
    expect(trigger.tag).to eq :poll
  end

  it 'reads type from DSL' do
    dsl = Nanoci::DSL::TriggerDSL.new(@component_factory, :poll_trigger)
    dsl.instance_eval do
      type :poll
      schedule 42
    end
    trigger = dsl.build
    expect(trigger.type).to eq :poll
  end
end
