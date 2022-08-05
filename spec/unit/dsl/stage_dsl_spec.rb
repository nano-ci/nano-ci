# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/dsl/stage_dsl'

RSpec.describe Nanoci::DSL::StageDSL do
  it 'reads tag from dsl' do
    dsl = Nanoci::DSL::StageDSL.new(nil, :stage, inputs: [])
    stage = dsl.build
    expect(stage.tag).to eq :stage
  end

  it 'reads inputs from dsl' do
    dsl = Nanoci::DSL::StageDSL.new(nil, :stage, inputs: [:abc])
    stage = dsl.build
    expect(stage.triggering_inputs).to eq [:abc]
  end

  it '#job adds new JobDSL to output' do
    dsl = Nanoci::DSL::StageDSL.new(nil, :stage, inputs: [:abc])
    # rubocop:disable Lint/EmptyBlock
    dsl.job(:tag) do
    end
    # rubocop:enable Lint/EmptyBlock

    stage = dsl.build
    expect(stage.jobs.empty?).to be false
  end
end
