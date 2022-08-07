# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/dsl/pipeline_dsl'
require 'nanoci/core/trigger'

RSpec.describe Nanoci::DSL::PipelineDSL do
  it 'reads pipeline tag from DSL' do
    dsl = Nanoci::DSL::PipelineDSL.new(nil, :pipe, 'test pipeline')
    pd = dsl.build
    expect(pd.tag).to eq :pipe
  end

  it 'reads pipeline name from DSL' do
    dsl = Nanoci::DSL::PipelineDSL.new(nil, :pipe, 'test pipeline')
    pd = dsl.build
    expect(pd.name).to eq 'test pipeline'
  end

  it 'reads trigger from DSL' do
    component_factory = double(:component_factory)
    trigger_factory = double(:component_factory)
    allow(component_factory).to receive(:triggers).and_return(trigger_factory)
    allow(trigger_factory).to receive(:build) do |tag, type, schedule|
      Nanoci::Core::Trigger.new(tag: tag, type: type)
    end
    dsl = Nanoci::DSL::PipelineDSL.new(component_factory, :pipe, 'test pipeline')
    dsl.instance_eval do
      trigger :poll do
      end
    end
    pipeline = dsl.build
    expect(pipeline.triggers.length).to eq 1
    expect(pipeline.triggers[0].tag).to eq :poll
  end

  it 'reads stage from DSL' do
    dsl = Nanoci::DSL::PipelineDSL.new(nil, :pipe, 'test pipeline')
    dsl.instance_eval do
      stage :test, inputs: [:'repo.abc'] do
      end
    end
    pipeline = dsl.build
    expect(pipeline.stages.length).to eq 1
    expect(pipeline.stages[0].tag).to eq :test
  end
end
