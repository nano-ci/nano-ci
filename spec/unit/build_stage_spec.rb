require 'spec_helper'

require 'nanoci/build_stage'
require 'nanoci/job'
require 'nanoci/project'
require 'nanoci/stage'

RSpec.describe Nanoci::BuildStage do
  it 'creates build job for for each job definition' do
    project = Nanoci::Project.new('tag' => 'test', 'name' => 'test project')
    job = Nanoci::Job.new(project, 'tag' => 'test-job')
    stage = Nanoci::Stage.new('tag' => 'test')
    stage.jobs = [job]

    build_stage = Nanoci::BuildStage.new(stage)
    expect(build_stage.jobs).not_to be_nil
    expect(build_stage.jobs.length).to eq(1)
    expect(build_stage.jobs[0].definition).to eq(job)
  end

  it 'creates build stage for for stage definition' do
    project = Nanoci::Project.new('tag' => 'test', 'name' => 'test project')
    job = Nanoci::Job.new(project, 'tag' => 'test-job')
    stage = Nanoci::Stage.new('tag' => 'test')
    stage.jobs = [job]

    build_stage = Nanoci::BuildStage.new(stage)
    expect(build_stage.definition).to eq(stage)
  end

  it 'to be QUEUED if at least one job is QUEUED and no UNDEFINED' do
    project = Nanoci::Project.new('tag' => 'test', 'name' => 'test project')
    stage = Nanoci::Stage.new('tag' => 'test')
    stage.jobs = [
      Nanoci::Job.new(project, 'tag' => 'test-job'),
      Nanoci::Job.new(project, 'tag' => 'test-job-1')
    ]

    build_stage = Nanoci::BuildStage.new(stage)
    build_stage.jobs[0].state = Nanoci::Build::State::QUEUED
    build_stage.jobs[1].state = Nanoci::Build::State::RUNNING
    expect(build_stage.state).to eq(Nanoci::Build::State::QUEUED)
  end

  it 'to be RUNNING if at least one job is RUNNING and no UNDEFINED or QUEUED' do
    project = Nanoci::Project.new('tag' => 'test', 'name' => 'test project')
    stage = Nanoci::Stage.new('tag' => 'test')
    stage.jobs = [
      Nanoci::Job.new(project, 'tag' => 'test-job'),
      Nanoci::Job.new(project, 'tag' => 'test-job-1')
    ]

    build_stage = Nanoci::BuildStage.new(stage)
    build_stage.jobs[0].state = Nanoci::Build::State::RUNNING
    build_stage.jobs[1].state = Nanoci::Build::State::ABORTED
    expect(build_stage.state).to eq(Nanoci::Build::State::RUNNING)
  end

  it 'to be ABORTED if at least one job is ABORTED and no UNDEFINED, QUEUED or RUNNING' do
    project = Nanoci::Project.new('tag' => 'test', 'name' => 'test project')
    stage = Nanoci::Stage.new('tag' => 'test')
    stage.jobs = [
      Nanoci::Job.new(project, 'tag' => 'test-job'),
      Nanoci::Job.new(project, 'tag' => 'test-job-1')
    ]

    build_stage = Nanoci::BuildStage.new(stage)
    build_stage.jobs[0].state = Nanoci::Build::State::ABORTED
    build_stage.jobs[1].state = Nanoci::Build::State::FAILED
    expect(build_stage.state).to eq(Nanoci::Build::State::ABORTED)
  end

  it 'to be FAILED if at least one job is FAILED and no UNDEFINED, QUEUED, RUNNING or ABORTED' do
    project = Nanoci::Project.new('tag' => 'test', 'name' => 'test project')
    stage = Nanoci::Stage.new('tag' => 'test')
    stage.jobs = [
      Nanoci::Job.new(project, 'tag' => 'test-job'),
      Nanoci::Job.new(project, 'tag' => 'test-job-1')
    ]

    build_stage = Nanoci::BuildStage.new(stage)
    build_stage.jobs[0].state = Nanoci::Build::State::FAILED
    build_stage.jobs[1].state = Nanoci::Build::State::COMPLETED
    expect(build_stage.state).to eq(Nanoci::Build::State::FAILED)
  end

  it 'to be COMPLETED if all jobs are COMPLETED' do
    project = Nanoci::Project.new('tag' => 'test', 'name' => 'test project')
    stage = Nanoci::Stage.new('tag' => 'test')
    stage.jobs = [
      Nanoci::Job.new(project, 'tag' => 'test-job'),
      Nanoci::Job.new(project, 'tag' => 'test-job-1')
    ]

    build_stage = Nanoci::BuildStage.new(stage)
    build_stage.jobs[0].state = Nanoci::Build::State::COMPLETED
    build_stage.jobs[1].state = Nanoci::Build::State::COMPLETED
    expect(build_stage.state).to eq(Nanoci::Build::State::COMPLETED)
  end
end
