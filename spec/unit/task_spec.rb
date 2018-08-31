# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/definition/task_definition'
require 'nanoci/task'

RSpec.describe Nanoci::Task do
  it 'reads type from src' do
    task_definition = Nanoci::Definition::TaskDefinition.new(
      type: 'make'
    )
    task = Nanoci::Task.new(task_definition, nil)
    expect(task.type).to eq :make
  end

  it 'required_agent_capabilities returns an empty Set' do
    task_definition = Nanoci::Definition::TaskDefinition.new(
      type: 'make'
    )
    task = Nanoci::Task.new(task_definition, nil)
    expect(task.required_agent_capabilities).to be_an Set
    expect(task.required_agent_capabilities.length).to eq 0
  end
end
