# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/build'
require 'nanoci/common_vars'
require 'nanoci/definition/project_definition'
require 'nanoci/definition/variable_definition'
require 'nanoci/project'
require 'nanoci/repo'
require 'nanoci/trigger'
require 'nanoci/variable'

RSpec.describe Nanoci::Build do
  it 'saves reference to project' do
    project_def = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-test',
      name: 'test project',
      stages: [{
        tag: 'test',
        jobs: [{
          tag: 'test-job'
        }]
      }]
    )
    project = Nanoci::Project.new(project_def)
    build = Nanoci::Build.run(project, nil, {})
    expect(build.project).to eq project
  end

  it 'saves reference to trigger' do
    project_def = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-test',
      name: 'test project',
      stages: [{
        tag: 'test',
        jobs: [{
          tag: 'test-job'
        }]
      }]
    )
    project = Nanoci::Project.new(project_def)
    trigger = Nanoci::Trigger.new(nil)
    build = Nanoci::Build.run(project, trigger, {})
    expect(build.trigger).to eq trigger
  end

  it 'merge project variables' do
    project_def = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-test',
      name: 'test project',
      stages: [{
        tag: 'test',
        jobs: [{
          tag: 'test-job'
        }]
      }],
      variables: [
        { tag: 'var1', value: 'var1 value' },
        { tag: 'var2', value: 'var2 value' }
      ]
    )
    project = Nanoci::Project.new(project_def)
    build = Nanoci::Build.run(project, nil, {})
    expect(build.variables).to include :var1
    expect(build.variables[:var1]).to eq 'var1 value'
    expect(build.variables).to include :var2
    expect(build.variables[:var2]).to eq 'var2 value'
  end

  it 'merge env variables' do
    project_def = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-test',
      name: 'test project',
      stages: [{
        tag: 'test',
        jobs: [{
          tag: 'test-job'
        }]
      }]
    )
    project = Nanoci::Project.new(project_def)
    env_vars = {
      :var1 => Nanoci::Variable.new(Nanoci::Definition::VariableDefinition.new(tag: 'var1', value: 'var1 value')),
      :var2 => Nanoci::Variable.new(Nanoci::Definition::VariableDefinition.new(tag: 'var2', value: 'var2 value'))
    }
    trigger = Nanoci::Trigger.new(nil)
    build = Nanoci::Build.run(project, trigger, env_vars)
    expect(build.variables).to include :var1
    expect(build.variables[:var1]).to eq 'var1 value'
    expect(build.variables).to include :var2
    expect(build.variables[:var2]).to eq 'var2 value'
  end

  it 'merge project and env variables' do
    project_def = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-test',
      name: 'test project',
      stages: [{
        tag: 'test',
        jobs: [{
          tag: 'test-job'
        }]
      }],
      variables: [
        { tag: 'var1', value: 'var1 value' },
        { tag: 'var2', value: 'var2 value' }
      ]
    )
    project = Nanoci::Project.new(project_def)
    env_vars = {
      :var3 => Nanoci::Variable.new(Nanoci::Definition::VariableDefinition.new(tag: 'var3', value: 'var3 value')),
      :var4 => Nanoci::Variable.new(Nanoci::Definition::VariableDefinition.new(tag: 'var4', value: 'var4 value'))
    }
    trigger = Nanoci::Trigger.new(nil)
    build = Nanoci::Build.run(project, trigger, env_vars)
    expect(build.variables).to include :var1
    expect(build.variables[:var1]).to eq 'var1 value'
    expect(build.variables).to include :var2
    expect(build.variables[:var2]).to eq 'var2 value'
    expect(build.variables).to include :var3
    expect(build.variables[:var3]).to eq 'var3 value'
    expect(build.variables).to include :var4
    expect(build.variables[:var4]).to eq 'var4 value'
  end

  it 'sets start time about now' do
    project_def = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-test',
      name: 'test project',
      stages: [{
        tag: 'test',
        jobs: [{
          tag: 'test-job'
        }]
      }],
      variables: [
        { tag: 'var1', value: 'var1 value' },
        { tag: 'var2', value: 'var2 value' }
      ]
    )
    project = Nanoci::Project.new(project_def)
    build = Nanoci::Build.run(project, nil, {})
    expect(build.start_time).to be_within(1).of(Time.now)
  end

  it 'sets tag using project tag and number' do
    project_def = Nanoci::Definition::ProjectDefinition.new(
      tag: 'tag-test',
      name: 'test project',
      stages: [{
        tag: 'test',
        jobs: [{
          tag: 'test-job'
        }]
      }],
      variables: [
        { tag: 'var1', value: 'var1 value' },
        { tag: 'var2', value: 'var2 value' }
      ]
    )
    project = Nanoci::Project.new(project_def)
    build = Nanoci::Build.run(project, nil, {})
    expect(build.tag).to eq('tag-test-1')
  end

  it 'sets sets current stage to project first stage' do
    project_def = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-test',
      name: 'test project',
      stages: [{
        tag: 'test',
        jobs: [{
          tag: 'test-job'
        }]
      }],
      variables: [
        { tag: 'var1', value: 'var1 value' },
        { tag: 'var2', value: 'var2 value' }
      ]
    )
    project = Nanoci::Project.new(project_def)
    build = Nanoci::Build.run(project, nil, {})
    expect(build.current_stage.definition).to eq(project.stages[0])
  end

  it 'sets build commits equal to project repo current commits' do
    project_def = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-test',
      name: 'test project',
      stages: [{
        tag: 'test',
        jobs: [{
          tag: 'test-job'
        }]
      }],
      variables: [
        { tag: 'var1', value: 'var1 value' },
        { tag: 'var2', value: 'var2 value' }
      ]
    )
    project = Nanoci::Project.new(project_def)
    repo = double('repo')
    allow(repo).to receive(:tag).and_return('repo-1')
    allow(repo).to receive(:current_commit).and_return('abcdef')
    allow(repo).to receive(:current_commit=)
    allow(repo).to receive(:update)
    allow(repo).to receive(:branch)
    allow(repo).to receive(:tip_of_tree)
    project.repos['repo-1'] = repo
    build = Nanoci::Build.run(project, nil, {})
    expect(build.commits).to include 'repo-1'
    expect(build.commits['repo-1']).to eq 'abcdef'
  end

  it 'initial state is QUEUED' do
    project_def = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-test',
      name: 'test project',
      stages: [{
        tag: 'test',
        jobs: [{
          tag: 'test-job'
        }]
      }],
      variables: [
        { tag: 'var1', value: 'var1 value' },
        { tag: 'var2', value: 'var2 value' }
      ]
    )
    project = Nanoci::Project.new(project_def)
    build = Nanoci::Build.run(project, nil, {})

    expect(build.state).to eq Nanoci::Build::State::QUEUED
  end

  it 'state is equal to current stage state' do
    project_def = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-test',
      name: 'test project',
      stages: [{
        tag: 'test',
        jobs: [{
          tag: 'test-job'
        }]
      }],
      variables: [
        { tag: 'var1', value: 'var1 value' },
        { tag: 'var2', value: 'var2 value' }
      ]
    )
    project = Nanoci::Project.new(project_def)
    build = Nanoci::Build.run(project, nil, {})

    expect(build.current_stage.state).to eq Nanoci::Build::State::QUEUED
    expect(build.state).to eq build.current_stage.state

    build.current_stage.jobs[0].state = Nanoci::Build::State::FAILED

    expect(build.current_stage.state).to eq Nanoci::Build::State::FAILED
    expect(build.state).to eq build.current_stage.state
  end

  it 'workdir equals to agent workdir + build tag' do
    project_def = Nanoci::Definition::ProjectDefinition.new(
      tag: 'project-path-test',
      name: 'test project',
      stages: [{
        tag: 'test',
        jobs: [{
          tag: 'test-job'
        }]
      }],
      variables: [
        { tag: 'var1', value: 'var1 value' },
        { tag: 'var2', value: 'var2 value' }
      ]
    )
    project = Nanoci::Project.new(project_def)
    build = Nanoci::Build.run(project, nil, {})
    env = { 'workdir' => '/abc' }

    expect(build.workdir(env)).to eq '/abc/project-path-test-1'
  end
end
