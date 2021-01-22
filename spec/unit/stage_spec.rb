# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/definition/stage_definition'
require 'nanoci/stage'

RSpec.describe Nanoci::Stage do
  it 'reads tag from definition' do
    definition = Nanoci::Definition::StageDefinition.new(tag: 'build-stage')
    stage = Nanoci::Stage.new(definition, nil)
    expect(stage.tag).to eq :'build-stage'
  end

  it 'sets jobs to initial value []' do
    definition = Nanoci::Definition::StageDefinition.new(tag: 'build-stage')
    stage = Nanoci::Stage.new(definition, nil)
    expect(stage.jobs).to be_an(Array)
    expect(stage.jobs.length).to eq 0
  end

  it 'reads jobs from definition' do
    definition = Nanoci::Definition::StageDefinition.new(
      tag: 'build-stage',
      jobs: [{
        tag: 'build-job'
      }]
    )
    stage = Nanoci::Stage.new(definition, nil)
    expect(stage.jobs[0]).to_not be_nil
    expect(stage.jobs[0].tag).to eq :'build-job'
  end
end
