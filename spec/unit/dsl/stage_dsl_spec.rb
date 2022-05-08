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
    expect(stage.inputs).to eq [:abc]
  end
end
