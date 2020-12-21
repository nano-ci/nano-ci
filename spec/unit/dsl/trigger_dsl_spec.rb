# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/dsl/trigger_dsl'

RSpec.describe Nanoci::DSL::TriggerDSL do
  it 'reads tag from DSL' do
    dsl = Nanoci::DSL::TriggerDSL.new(:poll)
    dsl.instance_eval do
      interval 42
    end
    td = dsl.build
    expect(td).to include(tag: :poll)
  end

  it 'reads type from DSL' do
    dsl = Nanoci::DSL::TriggerDSL.new(:poll_trigger)
    dsl.instance_eval do
      type :poll
      interval 42
    end
    td = dsl.build
    expect(td).to include(type: :poll)
  end

  it 'reads interval from DSL' do
    dsl = Nanoci::DSL::TriggerDSL.new(:poll)
    dsl.instance_eval do
      interval 42
    end
    trigger_def = dsl.build
    expect(trigger_def).to include(interval: 42)
  end
end
