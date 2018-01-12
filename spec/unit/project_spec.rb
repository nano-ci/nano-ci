require 'spec_helper'

require 'nanoci/project'

RSpec.describe Nanoci::Project do
  it 'reads tag from src' do
    project = Nanoci::Project.new('tag' => 'project-tag')
    expect(project.tag).to eq 'project-tag'
  end

  it 'reads name from src' do
    project = Nanoci::Project.new('name' => 'project name')
    expect(project.name).to eq 'project name'
  end
end
