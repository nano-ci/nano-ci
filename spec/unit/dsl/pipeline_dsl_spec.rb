# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/dsl/pipeline_dsl'
require 'nanoci/core/trigger'

RSpec.describe Nanoci::DSL::PipelineDSL do
  after(:each) do
    Nanoci::DSL::PipelineDSL.dsl_types.clear
  end

  it 'reads pipeline tag from DSL' do
    dsl = Nanoci::DSL::PipelineDSL.new(:pipe, 'test pipeline', :project)
    pd = dsl.build
    expect(pd.tag).to eq :pipe
  end

  it 'reads pipeline name from DSL' do
    dsl = Nanoci::DSL::PipelineDSL.new(:pipe, 'test pipeline', :project)
    pd = dsl.build
    expect(pd.name).to eq 'test pipeline'
  end

  it 'reads trigger from DSL' do
    Nanoci::DSL::PipelineDSL.dsl_types[:poll] = Nanoci::DSL::TriggerDSL
    dsl = Nanoci::DSL::PipelineDSL.new(:pipe, 'test pipeline', :project)
    dsl.instance_eval do
      # rubocop:disable Lint/EmptyBlock
      trigger :poll, :poll do
      end
      # rubocop:enable Lint/EmptyBlock
    end
    pipeline = dsl.build
    expect(pipeline.triggers.length).to eq 1
    expect(pipeline.triggers[0].tag).to eq :poll
  end

  it 'reads stage from DSL' do
    dsl = Nanoci::DSL::PipelineDSL.new(:pipe, 'test pipeline', :project)
    dsl.instance_eval do
      # rubocop:disable Lint/EmptyBlock
      stage :test, inputs: [:'repo.abc'] do
      end
      # rubocop:enable Lint/EmptyBlock
    end
    pipeline = dsl.build
    expect(pipeline.stages.length).to eq 1
    expect(pipeline.stages[0].tag).to eq :test
  end
end
