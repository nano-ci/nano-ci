# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/dsl/stage_dsl'

RSpec.describe Nanoci::DSL::StageDSL do
  it 'reads tag from dsl' do
    dsl = Nanoci::DSL::StageDSL.new(:stage, inputs: [])
    stage_def = dsl.build
    expect(stage_def).to include(tag: :stage)
  end

  it 'reads inputs from dsl' do
    dsl = Nanoci::DSL::StageDSL.new(:stage, inputs: [:abc])
    stage_def = dsl.build
    expect(stage_def).to include(inputs: [:abc])
  end
end
