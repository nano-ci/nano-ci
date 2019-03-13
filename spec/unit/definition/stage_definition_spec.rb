# frozen_string_literal: true

require 'nanoci/definition/stage_definition'

RSpec.describe Nanoci::Definition::StageDefinition do
  it 'reads tag' do
    hash = { tag: :abc }
    d = Nanoci::Definition::StageDefinition.new(hash)
    expect(d.tag).to eq :abc
  end

  it 'reads jobs' do
    hash = { jobs: [{}] }
    d = Nanoci::Definition::StageDefinition.new(hash)
    expect(d.jobs.size).to eq 1
  end

  it 'reads inpus' do
    hash = { inputs: ['input-var'] }
    d = Nanoci::Definition::StageDefinition.new(hash)
    expect(d.inputs).to include(:'input-var')
  end
end
