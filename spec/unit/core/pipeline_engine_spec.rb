# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/pipeline'
require 'nanoci/core/pipeline_engine'
require 'nanoci/core/project'
require 'nanoci/core/trigger'

# Test class to run trigger -> pipeline engine test cases
class PipelineTestTrigger < Nanoci::Core::Trigger
  def trigger_pulse
    on_pulse
  end
end

RSpec.describe Nanoci::Core::PipelineEngine do
  it '#run_project calls Pipeline#validate' do
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [],
      pipes: {}
    )
    expect(pipeline).to receive(:validate)
    project = Nanoci::Core::Project.new(name: 'abc', tag: :def, pipeline: pipeline)
    eng = Nanoci::Core::PipelineEngine.new(nil, nil)
    eng.run_project project
  end

  it '#run_project runs triggers' do
    trigger = double(:trigger)
    allow(trigger).to receive(:full_tag).and_return(:'trigger.test_trigger')
    allow(trigger).to receive(:pulse).and_return(Nanoci::System::Event.new)
    expect(trigger).to receive(:run)
    stage_a = Nanoci::Core::Stage.new(
      tag: :stage_tag,
      inputs: [],
      jobs: []
    )
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [trigger],
      stages: [stage_a],
      pipes: { 'trigger.test_trigger': [:stage_tag] }
    )

    project = Nanoci::Core::Project.new(name: 'proj', tag: :tag, pipeline: pipeline)

    eng = Nanoci::Core::PipelineEngine.new(nil, nil)
    eng.run_project project
  end

  it '#run_job schedule job execution on job_executor' do
    job_executor = double(:job_executor)
    expect(job_executor).to receive(:schedule_job_execution).with(
      :project,
      :stage,
      :job,
      :inputs,
      :prev_inputs
    )
    eng = Nanoci::Core::PipelineEngine.new(job_executor, nil)
    eng.run_job(:project, :stage, :job, :inputs, :prev_inputs)
  end

  it '#job_complete finalizes job and stage if all jobs are done' do
    job = Nanoci::Core::Job.new(tag: :job_tab, body: -> { })

    stage_a = Nanoci::Core::Stage.new(
      tag: :stage_tag,
      inputs: [],
      jobs: [job]
    )
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [stage_a],
      pipes: {}
    )
    project = Nanoci::Core::Project.new(name: 'proj', tag: :tag, pipeline: pipeline)

    project_repository = double(:project_repository)
    allow(project_repository).to receive(:find_by_tag).and_return(project)

    eng = Nanoci::Core::PipelineEngine.new(nil, project_repository)
    eng.run_project(project)

    pipeline_engine = double(:pipeline_engine)
    allow(pipeline_engine).to receive(:run_job)

    stage_a.run({ abc: 1 })

    eng.job_complete(project.tag, stage_a.tag, job.tag, { abc: 123 })

    expect(job.outputs).to include({ abc: 123 })
    expect(stage_a.outputs).to include({ abc: 123 })
  end

  it '#job_complete does not finalizes job and stage if not all jobs are done' do
    job_a = Nanoci::Core::Job.new(tag: :job_idle, body: -> { })
    job_b = Nanoci::Core::Job.new(tag: :job_running, body: -> { })

    stage_a = Nanoci::Core::Stage.new(
      tag: :stage_tag,
      inputs: [],
      jobs: [job_a, job_b]
    )
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [stage_a],
      pipes: {}
    )
    project = Nanoci::Core::Project.new(name: 'proj', tag: :tag, pipeline: pipeline)

    project_repository = double(:project_repository)
    allow(project_repository).to receive(:find_by_tag).and_return(project)

    eng = Nanoci::Core::PipelineEngine.new(nil, project_repository)
    eng.run_project(project)
    job_b.state = Nanoci::Core::Job::State::RUNNING

    eng.job_complete(project.tag, stage_a.tag, job_a.tag, { abc: 123 })

    expect(job_a.outputs).to include({ abc: 123 })
    expect(stage_a.outputs).to_not include({ abc: 123 })
  end

  it 'pipeline engine runs the next stage when trigger pulses' do
    trigger = PipelineTestTrigger.new(tag: :test_trigger)
    stage = double(:stage)
    allow(stage).to receive(:should_trigger?).and_return(true)
    allow(stage).to receive(:tag).and_return(:stage_tag)
    allow(stage).to receive(:inputs).and_return({ abc: 123 })
    allow(stage).to receive(:prev_inputs).and_return({ abc: 12 })
    expect(stage).to receive(:run).and_return([])
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipeline_tag,
      name: 'pipeline name',
      triggers: [trigger],
      stages: [stage],
      pipes: { 'trigger.test_trigger': [:stage_tag] }
    )

    project = Nanoci::Core::Project.new(name: 'proj', tag: :tag, pipeline: pipeline)

    project_repository = double(:project_repository)
    allow(project_repository).to receive(:find_by_tag).and_return(project)

    eng = Nanoci::Core::PipelineEngine.new(nil, project_repository)
    eng.run_project(project)
    trigger.trigger_pulse
  end
end
