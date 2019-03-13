# frozen_string_literal: true

require 'nanoci/definition/pipeline_definition'

RSpec.describe Nanoci::Definition::PipelineDefinition do
  it 'reads triggers' do
    hash = {
      triggers: [{
        type: :poll
      }]
    }
    pipeline_definition = Nanoci::Definition::PipelineDefinition.new(hash)
    expect(pipeline_definition.triggers.size).to eq 1
  end

  it 'reads stages' do
    hash = {
      stages: [{
        tag: :abc
      }]
    }
    pipeline_definition = Nanoci::Definition::PipelineDefinition.new(hash)
    expect(pipeline_definition.stages.size).to eq 1
  end

  it 'reads links' do
    hash = {
      links: [
        'abc -> def',
        'def -> ghi'
      ]
    }
    pipeline_definition = Nanoci::Definition::PipelineDefinition.new(hash)
    expect(pipeline_definition.links.size).to eq 2
    expect(pipeline_definition.links[0]).to eq [:abc, :def]
    expect(pipeline_definition.links[1]).to eq [:def, :ghi]
  end
end
