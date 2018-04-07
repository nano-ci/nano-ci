require 'spec_helper'

require 'nanoci/project'
require 'nanoci/repo'

RSpec.describe Nanoci::Project do
  it 'reads tag from src' do
    project = Nanoci::Project.new(tag: 'project-tag')
    expect(project.tag).to eq 'project-tag'
  end

  it 'reads name from src' do
    project = Nanoci::Project.new(name: 'project name')
    expect(project.name).to eq 'project name'
  end

  it 'state returns hash with tag' do
    project = Nanoci::Project.new(tag: 'project-tag')
    expect(project.state).to be_a Hash
    expect(project.state[:tag]).to eq 'project-tag'
  end

  it 'raises an error if tag does not match' do
    project = Nanoci::Project.new(tag: 'project-tag')
    invalid_state = { tag: 'not-a-project' }
    expect { project.state = invalid_state }.to raise_error('tag project-tag does not match state tag not-a-project')
  end

  it 'returns state of repos' do
    project = Nanoci::Project.new(tag: 'project-tag')
    project.repos = { 'project-repo' => Nanoci::Repo.new(tag: 'project-repo') }

    expect(project.state[:repos]).to_not be_nil
    expect(project.state[:repos]['project-repo']).to_not be_nil
  end

  it 'restores state of repo' do
    project = Nanoci::Project.new(tag: 'project-tag')
    project.repos = { 'project-repo' => Nanoci::Repo.new(tag: 'project-repo') }

    state = {
      tag: 'project-tag',
      repos: {
        'project-repo' => {
          tag: 'project-repo',
          current_commit: 'abc'
        }
      }
    }
    project.state = state
    expect(project.repos['project-repo'].current_commit).to eq 'abc'
  end

  it 'returns state of variables' do
    project = Nanoci::Project.new(tag: 'project-tag')
    project.variables = { 'var1' => Nanoci::Variable.new(tag: 'var1', value: 'abc') }

    expect(project.state[:variables]).to_not be_nil
    expect(project.state[:variables]['var1']).to_not be_nil
  end

  it 'restores state of variables' do
    project = Nanoci::Project.new(tag: 'project-tag')
    project.variables = { 'var1' => Nanoci::Variable.new(tag: 'var1', value: 'def') }

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
    expect(project.variables['var1'].value).to eq 'abc'
  end
end
