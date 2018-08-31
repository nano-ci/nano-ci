# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/definition/task_definition'
require 'nanoci/tasks/task_source_control'

RSpec.describe Nanoci::Tasks::TaskSourceControl do
  it 'reads repo_tag from src' do
    repo = double('repo')

    project = double('project')
    allow(project).to receive(:repos).and_return(:abc => repo)

    task_def = Nanoci::Definition::TaskDefinition.new(
      type: 'source-control',
      repo: 'abc',
      action: 'checkout'
    )
    task = Nanoci::Tasks::TaskSourceControl.new(task_def, project)
    expect(task.repo_tag).to eq :abc
  end

  it 'reads action from src' do
    repo = double('repo')

    project = double('project')
    allow(project).to receive(:repos).and_return(:abc => repo)

    task_def = Nanoci::Definition::TaskDefinition.new(
      type: 'source-control',
      repo: 'abc',
      action: 'checkout'
    )
    task = Nanoci::Tasks::TaskSourceControl.new(task_def, project)
    expect(task.action).to eq 'checkout'
  end

  it 'reads workdir from src' do
    repo = double('repo')

    project = double('project')
    allow(project).to receive(:repos).and_return(:abc => repo)

    task_def = Nanoci::Definition::TaskDefinition.new(
      type: 'source-control',
      repo: 'abc',
      action: 'checkout',
      workdir: '/home/project'
    )
    task = Nanoci::Tasks::TaskSourceControl.new(task_def, project)
    expect(task.workdir).to eq '/home/project'
  end

  it 'reads branch from src' do
    repo = double('repo')

    project = double('project')
    allow(project).to receive(:repos).and_return(:abc => repo)

    task_def = Nanoci::Definition::TaskDefinition.new(
      type: 'source-control',
      repo: 'abc',
      branch: 'master',
      action: 'checkout'
    )
    task = Nanoci::Tasks::TaskSourceControl.new(task_def, project)
    expect(task.branch).to eq 'master'
  end

  it 'returns required_output_capabilities from project repo' do
    repo = double('repo')
    expect(repo).to receive(:required_agent_capabilities).and_return(Set['def'])
    project = double('project')
    expect(project).to receive(:repos).and_return(abc: repo)

    task_def = Nanoci::Definition::TaskDefinition.new(
      type: 'source-control',
      repo: 'abc',
      branch: 'master',
      action: 'checkout'
    )
    task = Nanoci::Tasks::TaskSourceControl.new(task_def, project)
    expect(task.required_agent_capabilities).to include('def')
  end

  it 'execute fails if repo is missing' do
    project = double('project')
    allow(project).to receive(:repos).and_return({})

    task_def = Nanoci::Definition::TaskDefinition.new(
      type: 'source-control',
      repo: 'abc',
      action: 'checkout'
    )
    expect { Nanoci::Tasks::TaskSourceControl.new(task_def, project) }.to raise_error 'Missing repo definition abc'
  end

  it 'execute chdirs to working dir' do
    repo = double('repo')

    project = double('project')
    allow(project).to receive(:repos).and_return(abc: repo)

    build = double('build')
    allow(build).to receive(:project).and_return(project)
    output = double('output')
    allow(build).to receive(:workdir).and_return('/def/project-1')
    task_def = Nanoci::Definition::TaskDefinition.new(
      type: 'source-control',
      repo: 'abc',
      action: 'checkout',
      workdir: 'abc'
    )
    task = Nanoci::Tasks::TaskSourceControl.new(task_def, project)
    dir_double = class_double(Dir).as_stubbed_const
    expect(dir_double).to receive(:chdir).with('/def/project-1/abc')
    allow(dir_double).to receive(:exist?).and_return(true)
    task.execute(build, {})
  end

  it 'execute calls checkout with branch' do
    output = double('output')

    repo = double('repo')
    allow(repo).to receive(:exists?).and_return true
    allow(repo).to receive(:update)
    expect(repo).to receive(:checkout).with('master', {}, stderr: output, stdout: output)

    project = double('project')
    allow(project).to receive(:repos).and_return(abc: repo)

    build = double('build')
    allow(build).to receive(:project).and_return(project)
    allow(build).to receive(:workdir).and_return('/def/project-1')
    allow(build).to receive(:output).and_return(output)
    task_def = Nanoci::Definition::TaskDefinition.new(
      type: 'source-control',
      repo: 'abc',
      branch: 'master',
      workdir: 'abc',
      action: 'checkout'
    )
    task = Nanoci::Tasks::TaskSourceControl.new(task_def, project)
    dir_double = class_double(Dir).as_stubbed_const
    allow(dir_double).to receive(:chdir).and_yield
    allow(dir_double).to receive(:exist?).and_return(true)
    task.execute(build, {})
  end

  it 'execute_checkout calls checkout with branch' do
    output = double('output')

    repo = double('repo')
    allow(repo).to receive(:update)
    expect(repo).to receive(:checkout).with('master', {}, stderr: output, stdout: output)

    project = double('project')
    allow(project).to receive(:repos).and_return(abc: repo)

    task_def = Nanoci::Definition::TaskDefinition.new(
      type: 'source-control',
      repo: 'abc',
      branch: 'master',
      workdir: 'abc',
      action: 'checkout'
    )
    task = Nanoci::Tasks::TaskSourceControl.new(task_def, project)
    dir_double = class_double(Dir).as_stubbed_const
    allow(dir_double).to receive(:chdir).and_yield
    task.execute_checkout(repo, {}, output)
  end

  it 'execute_checkout updates repo' do
    output = double('output')

    repo = double('repo')
    allow(repo).to receive(:checkout)
    allow(repo).to receive(:update).with({})

    project = double('project')
    allow(project).to receive(:repos).and_return(abc: repo)

    task_def = Nanoci::Definition::TaskDefinition.new(
      type: 'source-control',
      repo: 'abc',
      branch: 'master',
      workdir: 'abc',
      action: 'checkout'
    )
    task = Nanoci::Tasks::TaskSourceControl.new(task_def, project)
    dir_double = class_double(Dir).as_stubbed_const
    allow(dir_double).to receive(:chdir).and_yield
    task.execute_checkout(repo, {}, output)
  end
end
