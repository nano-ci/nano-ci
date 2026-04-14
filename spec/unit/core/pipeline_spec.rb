# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/pipeline'

RSpec.describe Nanoci::Core::Pipeline do
  it '#initialize sets tag' do
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [],
      hooks: {}
    )

    expect(pipeline.tag).to eq :pipe_tag
  end

  it '#initialize sets name' do
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [],
      hooks: {}
    )

    expect(pipeline.name).to eq 'pipe name'
  end

  it '#initialize sets name' do
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [],
      hooks: {}
    )

    expect(pipeline.name).to eq 'pipe name'
  end

  it '#initialize sets stages array' do
    stage = Nanoci::Core::Stage.new(
      tag: :stage_tag,
      inputs: [],
      jobs: [],
      downstream: [],
      hooks: {}
    )

    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [stage],
      hooks: {}
    )

    expect(pipeline.stages).to include stage
  end

  it '#initialize sets triggers array' do
    trigger = Nanoci::Core::Trigger.new(tag: :trigger_tag, downstream: [])

    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [trigger],
      stages: [],
      hooks: {}
    )

    expect(pipeline.triggers).to include trigger
  end

  it '#initialize sets downstream on trigger and stage' do
    trigger = Nanoci::Core::Trigger.new(tag: :trigger_tag, downstream: [:stage_tag])
    stage = Nanoci::Core::Stage.new(
      tag: :stage_tag,
      inputs: [],
      jobs: [],
      downstream: [],
      hooks: {}
    )

    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [trigger],
      stages: [stage],
      hooks: {}
    )

    expect(pipeline.triggers.first.downstream).to include(:stage_tag)
  end

  it '#validate raises ArgumentError if pipeline contains duplicate stages' do
    stage_a = Nanoci::Core::Stage.new(
      tag: :stage_tag,
      inputs: [],
      jobs: [],
      downstream: [],
      hooks: {}
    )
    stage_b = Nanoci::Core::Stage.new(
      tag: :stage_tag,
      inputs: [],
      jobs: [],
      downstream: [],
      hooks: {}
    )

    stages = [stage_a, stage_b]

    expect { Nanoci::Core::Pipeline.new(tag: :p, name: 'p', triggers: [], stages: stages, hooks: {}) }
      .to raise_error(ArgumentError)
  end
end
