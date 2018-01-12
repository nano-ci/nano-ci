require 'spec_helper'

require 'nanoci/stage'

RSpec.describe Nanoci::Stage do
  it 'tag from src' do
    stage = Nanoci::Stage.new('tag' => 'build-stage')
    expect(stage.tag).to eq 'build-stage'
  end

  it 'sets jobs to initial value []' do
    stage = Nanoci::Stage.new
    expect(stage.jobs).to be_an(Array)
    expect(stage.jobs.length). to eq 0
  end
end
