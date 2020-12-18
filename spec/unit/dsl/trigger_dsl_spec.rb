# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/dsl/trigger_dsl'

RSpec.describe Nanoci::DSL::TriggerDSL do
  it 'reads repo tag from DSL' do
    dsl = Nanoci::DSL::TriggerDSL.new(:poll)
    dsl.instance_eval do
      repo :abc
    end
    trigger_def = dsl.build
    expect(trigger_def).to include(repo: :abc)
  end

  it 'reads schedule from DSL' do
    dsl = Nanoci::DSL::TriggerDSL.new(:poll)
    dsl.instance_eval do
      schedule 42
    end
    trigger_def = dsl.build
    expect(trigger_def).to include(schedule: 42)
  end
end
