# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/definition/project_definition'

RSpec.describe Nanoci::Definition::ProjectDefinition do
  it 'reads name from src' do
    src = { name: 'project name' }
    project_definition = Nanoci::Definition::ProjectDefinition.new(src)
    expect(project_definition.name).to eq 'project name'
  end

  it 'reads tag from src' do
    src = { tag: :project_tag }
    project_definition = Nanoci::Definition::ProjectDefinition.new(src)
    expect(project_definition.tag).to eq :project_tag
  end

  it 'reads repos from src' do
    src = { tag: :project_tag, repos: [{ tag: :repo, type: :git, src: 'abc'}] }
    project_definition = Nanoci::Definition::ProjectDefinition.new(src)
    expect(project_definition.repos.size).to eq 1
  end

  it 'reads stages from src' do
    src = { tag: :project_tag, stages: [{}] }
    project_definition = Nanoci::Definition::ProjectDefinition.new(src)
    expect(project_definition.stages.size).to eq 1
  end

  it 'reads variables from src' do
    src = { tag: :project_tag, variables: [{}] }
    project_definition = Nanoci::Definition::ProjectDefinition.new(src)
    expect(project_definition.variables.size).to eq 1
  end
end
