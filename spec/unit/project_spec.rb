# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/project'
require 'nanoci/repo'

RSpec.describe Nanoci::Project do
  it 'reads tag from src' do
    project = Nanoci::Project.new(tag: 'project-tag', name: 'project name')
    expect(project.tag).to eq 'project-tag'
  end

  it 'reads name from src' do
    project = Nanoci::Project.new(tag: 'project-tag', name: 'project name')
    expect(project.name).to eq 'project name'
  end

  it 'state returns hash with tag' do
    project = Nanoci::Project.new(tag: 'project-tag', name: 'project name')
    expect(project.state).to be_a Hash
    expect(project.state[:tag]).to eq 'project-tag'
  end

  it 'raises an error if tag does not match' do
    project = Nanoci::Project.new(tag: 'project-tag', name: 'project name')
    invalid_state = { tag: 'not-a-project' }
    expect { project.state = invalid_state }.to raise_error('tag project-tag does not match state tag not-a-project')
  end

  it 'reades repo from definition' do
    project = Nanoci::Project.new(
      tag: 'project-tag',
      name: 'project name',
      repos: [{
        tag: 'test repo',
        type: 'test',
        uri: 'abc'
      }]
    )
    expect(project.repos[:'test repo']).to be_a(Nanoci::Repo)
  end
end
