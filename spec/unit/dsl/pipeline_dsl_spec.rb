# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/dsl/pipeline_dsl'

RSpec.describe Nanoci::DSL::PipelineDSL do
  it 'reads pipeline tag from DSL' do
    dsl = Nanoci::DSL::PipelineDSL.new(:pipe, 'test pipeline')
    pd = dsl.build
    expect(pd).to include(tag: :pipe)
  end

  it 'reads pipeline tag from DSL' do
    dsl = Nanoci::DSL::PipelineDSL.new(:pipe, 'test pipeline')
    pd = dsl.build
    expect(pd).to include(name: 'test pipeline')
  end

  it 'reads trigger from DSL' do
    dsl = Nanoci::DSL::PipelineDSL.new(:pipe, 'test pipeline')
    dsl.instance_eval do
      trigger :poll do
      end
    end
    pipeline_def = dsl.build
    expect(pipeline_def[:triggers].length).to eq 1
    expect(pipeline_def[:triggers][0][:tag]).to eq :poll
  end

  it 'reads stage from DSL' do
    dsl = Nanoci::DSL::PipelineDSL.new(:pipe, 'test pipeline')
    dsl.instance_eval do
      stage :test, inputs: [:'repo.abc'] do
      end
    end
    pipeline_def = dsl.build
    expect(pipeline_def).to include :stages
    expect(pipeline_def[:stages].length).to eq 1
    expect(pipeline_def[:stages][0][:tag]).to eq :test
  end
end
