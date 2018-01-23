require 'spec_helper'

require 'nanoci/tasks/task_source_control'

RSpec.describe Nanoci::Tasks::TaskSourceControl do
  it 'saves repo_tag from src' do
    task = Nanoci::Tasks::TaskSourceControl.new('repo' => 'abc')
    expect(task.repo_tag).to eq 'abc'
  end

  it 'saves action from src' do
    task = Nanoci::Tasks::TaskSourceControl.new('action' => 'checkout')
    expect(task.action).to eq 'checkout'
  end

  it 'saves workdir from src' do
    task = Nanoci::Tasks::TaskSourceControl.new('workdir' => '/home/project')
    expect(task.workdir).to eq '/home/project'
  end

  it 'saves branch from src' do
    task = Nanoci::Tasks::TaskSourceControl.new('branch' => 'master')
    expect(task.branch).to eq 'master'
  end

  it 'returns required_agent_capabilities from project repo' do
    task = Nanoci::Tasks::TaskSourceControl.new('repo' => 'abc')
    repo = double('repo')
    expect(repo).to receive(:required_agent_capabilities).and_return(Set['def'])
    project = double('project')
    expect(project).to receive(:repos).and_return('abc' => repo)
    expect(task.required_agent_capabilities(project)).to include('def')
  end

  it 'execute fails if repo is missing' do
    project = double('project')
    allow(project).to receive(:repos).and_return({ })

    build = double('build')
    allow(build).to receive(:project).and_return(project)
    task = Nanoci::Tasks::TaskSourceControl.new('repo' => 'abc')
    expect { task.execute(build, nil) }.to raise_error 'Missing repo definition abc'
  end

  it 'execute chdirs to working dir' do
    repo = double('repo')

    project = double('project')
    allow(project).to receive(:repos).and_return({ 'abc' => repo })

    build = double('build')
    allow(build).to receive(:project).and_return(project)
    agent = double('agent')
    allow(build).to receive(:workdir).and_return('/def/project-1')
    task = Nanoci::Tasks::TaskSourceControl.new('repo' => 'abc', 'workdir' => 'abc')
    dir_double = class_double(Dir).as_stubbed_const
    expect(dir_double).to receive(:chdir).with('/def/project-1/abc')
    task.execute(build, agent)
  end
end
