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
      pipes: {}
    )

    expect(pipeline.tag).to eq :pipe_tag
  end

  it '#initialize sets name' do
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [],
      pipes: {}
    )

    expect(pipeline.name).to eq 'pipe name'
  end

  it '#initialize sets name' do
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [],
      pipes: {}
    )

    expect(pipeline.name).to eq 'pipe name'
  end

  it '#initialize sets stages array' do
    stage = Nanoci::Core::Stage.new(
      tag: :stage_tag,
      inputs: [],
      jobs: []
    )

    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [stage],
      pipes: {}
    )

    expect(pipeline.stages).to include stage
  end

  it '#initialize sets triggers array' do
    trigger = Nanoci::Core::Trigger.new(tag: :trigger_tag, type: :test)


    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [trigger],
      stages: [],
      pipes: {}
    )

    expect(pipeline.triggers).to include trigger
  end

  it '#initialize sets pipes' do
    trigger = Nanoci::Core::Trigger.new(tag: :trigger_tag, type: :test)
    stage = Nanoci::Core::Stage.new(
      tag: :stage_tag,
      inputs: [],
      jobs: []
    )

    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [trigger],
      stages: [stage],
      pipes: { 'trigger.trigger_tag': [:stage_tag] }
    )

    expect(pipeline.pipes).to include({ 'trigger.trigger_tag': [:stage_tag] })
  end
end
