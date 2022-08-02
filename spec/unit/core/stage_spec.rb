# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/stage'

RSpec.describe Nanoci::Core::Stage do
  it '#initialize sets #tag' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [], jobs: [])
    expect(stage.tag).to be(:'stage-tag')
  end

  it '#initialize sets #triggering_inputs' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [:abc], jobs: [])
    expect(stage.triggering_inputs).to include(:abc)
  end

  it '#initialize sets #jobs' do
    job = Nanoci::Core::Job.new(tag: 'build-job', body: nil, work_dir: 'local')
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [], jobs: [job])
    expect(stage.jobs).to include(job)
  end

  it '#initialize sets stage state to IDLE' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [], jobs: [])
    expect(stage.state).to be(Nanoci::Core::Stage::State::IDLE)
  end

  it '#should_trigger? returns true if triggering_inputs is empty' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [], jobs: [])
    expect(stage.should_trigger?({ abc: 0 })).to be true
  end

  it '#should_trigger? returns true if current inputs has no value' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [:abc], jobs: [])
    expect(stage.inputs).not_to include(:abc)
    expect(stage.should_trigger?({ abc: 1 })).to be true
  end

  it '#should_trigger? returns true if next input is not equal to current inputs' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [:abc], jobs: [])
    memento = {
      inputs: {
        abc: 0
      }
    }
    stage.restore_memento(memento)
    expect(stage.inputs[:abc]).not_to eq 1
    expect(stage.should_trigger?({ abc: 1 })).to be true
  end

  it '#should_trigger? returns true if next input is equal to current inputs' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [:abc], jobs: [])
    memento = {
      inputs: {
        abc: 1
      }
    }
    stage.restore_memento(memento)
    expect(stage.inputs[:abc]).to eq 1
    expect(stage.should_trigger?({ abc: 1 })).to be false
  end
end
