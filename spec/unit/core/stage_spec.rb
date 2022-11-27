# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/stage'

RSpec.describe Nanoci::Core::Stage do
  it '#initialize sets #tag' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [], jobs: [], hooks: {})
    expect(stage.tag).to be(:'stage-tag')
  end

  it '#initialize sets #triggering_inputs' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [:abc], jobs: [], hooks: {})
    expect(stage.triggering_inputs).to include(:abc)
  end

  it '#initialize sets #jobs' do
    job = Nanoci::Core::Job.new(tag: 'build-job', body: nil, work_dir: 'local')
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [], jobs: [job], hooks: {})
    expect(stage.jobs).to include(job)
  end

  it '#initialize sets stage state to IDLE' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [], jobs: [], hooks: {})
    expect(stage.state).to be(Nanoci::Core::Stage::State::IDLE)
  end

  it '#should_trigger? returns true if triggering_inputs is empty' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [], jobs: [], hooks: {})
    expect(stage.should_trigger?({ abc: 0 })).to be true
  end

  it '#should_trigger? returns true if current inputs has no value' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [:abc], jobs: [], hooks: {})
    expect(stage.inputs).not_to include(:abc)
    expect(stage.should_trigger?({ abc: 1 })).to be true
  end

  it '#should_trigger? returns true if next input is not equal to current inputs' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [:abc], jobs: [], hooks: {})
    memento = {
      tag: :'stage-tag',
      state: :idle,
      inputs: {
        abc: 0
      }
    }
    stage.memento = memento
    expect(stage.inputs[:abc]).not_to eq 1
    expect(stage.should_trigger?({ abc: 1 })).to be true
  end

  it '#should_trigger? returns true if next input is equal to current inputs' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [:abc], jobs: [], hooks: {})
    memento = {
      tag: :'stage-tag',
      state: :idle,
      inputs: {
        abc: 1
      }
    }
    stage.memento = memento
    expect(stage.inputs[:abc]).to eq 1
    expect(stage.should_trigger?({ abc: 1 })).to be false
  end

  it '#run stores current inputs to prev_inputs and merge next_inputs into current' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [:abc], jobs: [], hooks: {})
    memento = {
      tag: :'stage-tag',
      state: :idle,
      inputs: {
        abc: 1,
        aaa: 1
      }
    }
    stage.memento = memento
    stage.run({ abc: 2, def: 3 })
    expect(stage.prev_inputs).to include({ abc: 1 })
    expect(stage.inputs).to include({ aaa: 1, abc: 2, def: 3 })
  end

  it '#run sets state to RUNNING' do
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [:abc], jobs: [], hooks: {})
    memento = {
      tag: :'stage-tag',
      state: :idle,
      inputs: {
        abc: 1
      }
    }
    stage.memento = memento
    stage.run({ abc: 2 })
    expect(stage.state).to be Nanoci::Core::Stage::State::RUNNING
  end

  it '#run calls pipeline_engine to run jobs' do
    job = Nanoci::Core::Job.new(tag: :job, body: -> {})
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [:abc], jobs: [job], hooks: {})
    memento = {
      tag: :'stage-tag',
      state: :idle,
      inputs: {
        abc: 1
      }
    }
    stage.memento = memento

    expect(stage.run({ abc: 2 })).to include(job)
  end

  it '#finalize sets stage state to IDLE' do
    job = Nanoci::Core::Job.new(tag: :job, body: -> {})
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [:abc], jobs: [job], hooks: {})
    memento = {
      tag: :'stage-tag',
      state: :idle,
      inputs: {
        abc: 1
      }
    }
    stage.memento = memento

    stage.run({ abc: 2 })

    expect(stage.state).to be Nanoci::Core::Stage::State::RUNNING

    stage.finalize

    expect(stage.state).to be Nanoci::Core::Stage::State::IDLE
  end

  it '#finalize merges #pending_outputs to #outputs if stage is successful' do
    job = double(:job)
    allow(job).to receive(:success).and_return(true)
    allow(job).to receive(:outputs).and_return({ def: 321 })
    allow(job).to receive(:state).and_return(Nanoci::Core::Job::State::IDLE)
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [], jobs: [job], hooks: {})
    stage.run({ abc: 1 })

    expect(stage.outputs.empty?).to be true

    stage.finalize

    expect(stage.outputs).to include({ def: 321 })
  end

  it '#jobs_idle? returns true if all jobs are not running' do
    job = double(:job)
    allow(job).to receive(:state).and_return(Nanoci::Core::Job::State::IDLE)
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [:abc], jobs: [job], hooks: {})
    expect(stage.jobs_idle?).to be true
  end

  it '#jobs_idle? returns false if some jobs are running' do
    job1 = double(:job)
    allow(job1).to receive(:state).and_return(Nanoci::Core::Job::State::IDLE)
    job2 = double(:job)
    allow(job2).to receive(:state).and_return(Nanoci::Core::Job::State::RUNNING)
    stage = Nanoci::Core::Stage.new(tag: :'stage-tag', inputs: [:abc], jobs: [job1, job2], hooks: {})
    expect(stage.jobs_idle?).to be false
  end

  it '#validate raises ArgumentError if #tag is nil' do
    stage = Nanoci::Core::Stage.new(tag: nil, inputs: [], jobs: [], hooks: {})
    expect { stage.validate }.to raise_error ArgumentError
  end

  it '#validate raises ArgumentError if #tag is not a Symbol' do
    stage = Nanoci::Core::Stage.new(tag: 123, inputs: [], jobs: [], hooks: {})
    expect { stage.validate }.to raise_error ArgumentError
  end

  it '#validate raises ArgumentError if #triggering_inputs is nil' do
    stage = Nanoci::Core::Stage.new(tag: :tag, inputs: nil, jobs: [], hooks: {})
    expect { stage.validate }.to raise_error ArgumentError
  end

  it '#validate raises ArgumentError if #triggering_inputs is not an Array' do
    stage = Nanoci::Core::Stage.new(tag: :tag, inputs: 123, jobs: [], hooks: {})
    expect { stage.validate }.to raise_error ArgumentError
  end

  it '#validate raises ArgumentError if #jobs is nil' do
    stage = Nanoci::Core::Stage.new(tag: :tag, inputs: [], jobs: nil, hooks: {})
    expect { stage.validate }.to raise_error ArgumentError
  end

  it '#validate raises ArgumentError if #jobs is not an Array' do
    stage = Nanoci::Core::Stage.new(tag: :tag, inputs: [], jobs: 123, hooks: {})
    expect { stage.validate }.to raise_error ArgumentError
  end

  it '#validate calls #validate on jobs' do
    job = double(:job)
    expect(job).to receive(:validate)
    stage = Nanoci::Core::Stage.new(tag: :tag, inputs: [], jobs: [job], hooks: {})
    expect { stage.validate }.not_to raise_error ArgumentError
  end
end
