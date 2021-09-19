# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/definition/project_definition'
require 'nanoci/project'
require 'nanoci/repo'

RSpec.describe Nanoci::Project do
  before(:all) do
    Nanoci.resources.push
    class TestRepo < Nanoci::Repo
      provides 'test'
    end
  end

  after(:all) do
    Nanoci.resources.pop
  end

  it 'reads tag from src' do
    definition = Nanoci::Definition::ProjectDefinition.new(tag: 'project-tag')
    project = Nanoci::Project.new(definition)
    expect(project.tag).to eq 'project-tag'
  end

  it 'reads name from src' do
    definition = Nanoci::Definition::ProjectDefinition.new(tag: 'project-tag', name: 'project name')
    project = Nanoci::Project.new(definition)
    expect(project.name).to eq 'project name'
  end

  it 'state returns hash with tag' do
    definition = Nanoci::Definition::ProjectDefinition.new(tag: 'project-tag')
    project = Nanoci::Project.new(definition)
    expect(project.state).to be_a Hash
    expect(project.state[:tag]).to eq 'project-tag'
  end

  it 'raises an error if tag does not match' do
    definition = Nanoci::Definition::ProjectDefinition.new(tag: 'project-tag')
    project = Nanoci::Project.new(definition)
    invalid_state = { tag: 'not-a-project' }
    expect { project.state = invalid_state }.to raise_error('tag project-tag does not match state tag not-a-project')
  end

  it 'returns state of repos' do
    definition = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-tag',
      repos: [{
        tag: 'project-repo',
        type: 'test',
        src: 'abc'
      }]
    )
    project = Nanoci::Project.new(definition)

    expect(project.state[:repos]).to_not be_nil
    expect(project.state[:repos][:'project-repo']).to_not be_nil
  end

  it 'restores state of repo' do
    definition = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-tag',
      repos: [{
        tag: 'project-repo',
        type: 'test',
        src: 'abc'
      }]
    )
    project = Nanoci::Project.new(definition)

    state = {
      tag: 'project-tag',
      repos: {
        'project-repo' => {
          tag: 'project-repo',
          current_commit: 'abc',
          src: 'abc'
        }
      }
    }
    project.state = state
    expect(project.repos[:'project-repo'].current_commit).to eq 'abc'
  end

  it 'returns state of variables' do
    definition = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-tag',
      variables: [{
        tag: 'var1',
        value: 'abc'
      }]
    )
    project = Nanoci::Project.new(definition)

    expect(project.state[:variables]).to_not be_nil
    expect(project.state[:variables][:var1]).to_not be_nil
  end

  it 'restores state of variables' do
    definition = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-tag',
      variables: [{
        tag: 'var1',
        value: 'abc'
      }]
    )
    project = Nanoci::Project.new(definition)

    state = {
      tag: 'project-tag',
      variables: {
        'var1' => {
          tag: 'var1',
          value: 'abc'
        }
      }
    }

    project.state = state
    expect(project.variables[:var1].value).to eq 'abc'
  end

  it 'reades repo from definition' do
    definition = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-tag',
      repos: [{
        tag: 'test repo',
        type: 'test',
        src: 'abc'
      }]
    )

    project = Nanoci::Project.new(definition)
    expect(project.repos[:'test repo']).to be_a(TestRepo)
  end

  it 'reads stages from definition' do
    definition = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-tag',
      stages: [{
        tag: 'project-stage'
      }]
    )

    project = Nanoci::Project.new(definition)
    expect(project.stages[0]).to_not be_nil
    expect(project.stages[0].tag).to eq :'project-stage'
  end
end
