# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/pipeline'
require 'nanoci/core/pipeline_engine'
require 'nanoci/core/project'
require 'nanoci/core/trigger'

# Test class to run trigger -> pipeline engine test cases
class PipelineTestTrigger < Nanoci::Core::Trigger
  def trigger_pulse
    pulse
  end
end

RSpec.describe Nanoci::Core::PipelineEngine do
  it '#run_project calls Pipeline#validate' do
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [],
      pipes: {},
      hooks: {}
    )
    project = Nanoci::Core::Project.new(name: 'abc', tag: :def, pipeline: pipeline)
    project_repository = double(:project_repository, save: nil)
    eng = Nanoci::Core::PipelineEngine.new(nil, project_repository)
    eng.run_project project
  end

  it '#run_job schedule job execution on job_executor' do
    job_executor = double(:job_executor)
    job = double(:job)
    allow(job).to receive(:state=)
    expect(job_executor).to receive(:schedule_job_execution).with(
      job,
      :inputs,
      :prev_inputs
    )
    eng = Nanoci::Core::PipelineEngine.new(job_executor, nil)
    eng.run_job(job, :inputs, :prev_inputs)
  end

  it '#job_complete finalizes job and stage if all jobs are done' do
    project_tag = :tag
    stage_a_tag = :stage_tag
    job = Nanoci::Core::Job.new(tag: :job_tab, body: -> {})

    stage_a = Nanoci::Core::Stage.new(
      tag: stage_a_tag,
      inputs: [],
      jobs: [job],
      hooks: {}
    )
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [stage_a],
      pipes: {},
      hooks: {}
    )
    project = Nanoci::Core::Project.new(name: 'proj', tag: project_tag, pipeline: pipeline)

    project_repository = double(:project_repository)
    expect(project_repository).to receive(:save).twice

    job_executor = double(:job_executor)
    allow(job_executor).to receive(:schedule_job_execution)

    eng = Nanoci::Core::PipelineEngine.new(job_executor, project_repository)
    eng.run_project(project)

    pipeline_engine = double(:pipeline_engine)
    allow(pipeline_engine).to receive(:run_job)

    stage_a.run({ abc: 1 })

    eng.job_complete(job, { abc: 123 })

    expect(job.outputs).to include({ abc: 123 })
    expect(stage_a.outputs).to include({ abc: 123 })
  end

  it '#job_complete does not finalizes job and stage if not all jobs are done' do
    job_a = Nanoci::Core::Job.new(tag: :job_idle, body: -> {})
    job_b = Nanoci::Core::Job.new(tag: :job_running, body: -> {})

    stage_a = Nanoci::Core::Stage.new(
      tag: :stage_tag,
      inputs: [],
      jobs: [job_a, job_b],
      hooks: {}
    )
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [stage_a],
      pipes: {},
      hooks: {}
    )
    project = Nanoci::Core::Project.new(name: 'proj', tag: :tag, pipeline: pipeline)

    project_repository = double(:project_repository)
    allow(project_repository).to receive(:find_by_tag).and_return(project)
    expect(project_repository).to receive(:save).twice

    eng = Nanoci::Core::PipelineEngine.new(nil, project_repository)
    eng.run_project(project)
    job_b.state = Nanoci::Core::Job::State::RUNNING

    eng.job_complete(job_a, { abc: 123 })

    expect(job_a.outputs).to include({ abc: 123 })
    expect(stage_a.outputs).to_not include({ abc: 123 })
  end

  it 'pipeline engine runs the next stage when trigger pulses' do
    project_tag = :tag
    trigger = PipelineTestTrigger.new(tag: :test_trigger)
    stage = Nanoci::Core::Stage.new(
      tag: :stage_tag,
      inputs: [],
      jobs: [],
      hooks: []
    )
    memento = stage.memento
    memento[:inputs] = { abc: 123 }
    memento[:prev_inputs] = { abc: 12 }
    stage.memento = memento
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipeline_tag,
      name: 'pipeline name',
      triggers: [trigger],
      stages: [stage],
      pipes: { 'trigger.test_trigger': [:stage_tag] },
      hooks: {}
    )

    project = Nanoci::Core::Project.new(name: 'proj', tag: project_tag, pipeline: pipeline)

    project_repository = double(:project_repository)
    allow(project_repository).to receive(:find_by_tag).and_return(project)
    allow(project_repository).to receive(:save)

    eng = Nanoci::Core::PipelineEngine.new(nil, project_repository)
    eng.run_project(project)
    outputs = trigger.pulse
    eng.trigger_fired(trigger.project.tag, trigger.full_tag, outputs)
    expect(stage.state).to eq(Nanoci::Core::Stage::State::RUNNING)
  end
end
