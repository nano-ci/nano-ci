require 'spec_helper'

require 'nanoci/project_loader'
require 'nanoci/repo'
require 'nanoci/task'

class ProjectLoaderTestRepo < Nanoci::Repo
  attr_accessor :data
  def initialize(data)
    super(data)
    @data = data
  end
end

Nanoci::Repo.types['git'] = ProjectLoaderTestRepo

class ProjectLoaderTestTask < Nanoci::Task
  attr_accessor :data
  def initialize(data)
    super(data)
    @data = data
  end
end

Nanoci::Task.types['artifact'] = ProjectLoaderTestTask
Nanoci::Task.types['junit'] = ProjectLoaderTestTask
Nanoci::Task.types['make'] = ProjectLoaderTestTask
Nanoci::Task.types['source-control'] = ProjectLoaderTestTask

RSpec.describe Nanoci::ProjectLoader do
  it 'reads project properties from yaml' do
    project = Nanoci::ProjectLoader.load('samples/sample.nanoci')

    expect(project).not_to be_nil
    expect(project.repos).to include 'main-repo'
    expect(project.stages.length).to eq 3
    expect(project.stages[0].tag).to eq 'build'
    expect(project.stages[1].tag).to eq 'unit-tests'
    expect(project.stages[2].tag).to eq 'func-tests'
    expect(project.variables).to be_a Hash
    expect(project.variables.length).to eq 2
    expect(project.variables['var1'].value).to eq 'abc'
    expect(project.variables['var2'].value).to eq '${var1}-def'
  end
end
