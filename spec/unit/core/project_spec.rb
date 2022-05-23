# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/pipeline'
require 'nanoci/core/project'
require 'nanoci/core/repo'

RSpec.describe Nanoci::Core::Project do
  before(:each) do
    @pipeline = Nanoci::Core::Pipeline.new(
      tag: :tag,
      name: 'name',
      triggers: [],
      stages: [],
      pipes: {}
    )
  end

  it 'reads tag from src' do
    project = Nanoci::Core::Project.new(tag: :'project-tag', name: 'project name', pipeline: @pipeline)
    expect(project.tag).to eq :'project-tag'
  end

  it 'reads name from src' do
    project = Nanoci::Project.new(tag: 'project-tag', name: 'project name', pipeline: @pipeline)
    expect(project.name).to eq 'project name'
  end

  it 'reades repo from definition' do
    repo = Nanoci::Core::Repo.new(:tag, :git, 'abc')
    project = Nanoci::Project.new(
      tag: :'project-tag',
      name: 'project name',
      repos: [repo]
    )
    expect(project.repos).to include(repo)
  end
end
