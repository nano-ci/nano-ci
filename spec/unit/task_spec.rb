require 'spec_helper'

require 'nanoci/task'

RSpec.describe Nanoci::Task do
  it 'Task.types returns a Hash' do
    expect(Nanoci::Task.types).to be_a Hash
  end

  it 'reads type from src' do
    task = Nanoci::Task.new(type: 'make')
    expect(task.type).to eq 'make'
  end

  it 'required_agent_capabilities returns an empty Set' do
    task = Nanoci::Task.new(type: 'make')
    expect(task.required_agent_capabilities(nil)).to be_an Set
    expect(task.required_agent_capabilities(nil).length).to eq 0
  end
end
