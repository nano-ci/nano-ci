# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/pipeline_engine'

RSpec.describe Nanoci::Core::PipelineEngine do
  it '#run_pipeline calls Pipeline#validate' do
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [],
      pipes: {}
    )
    expect(pipeline).to receive(:validate)
    eng = Nanoci::Core::PipelineEngine.new(nil)
    eng.run_pipeline pipeline
  end

  it '#run_pipeline raises ArgumentError if pipeline contains duplicate stages' do
    stage_a = Nanoci::Core::Stage.new(
      tag: :stage_tag,
      inputs: [],
      jobs: []
    )
    stage_b = Nanoci::Core::Stage.new(
      tag: :stage_tag,
      inputs: [],
      jobs: []
    )
    pipeline = Nanoci::Core::Pipeline.new(
      tag: :pipe_tag,
      name: 'pipe name',
      triggers: [],
      stages: [stage_a, stage_b],
      pipes: {}
    )

    eng = Nanoci::Core::PipelineEngine.new(nil)
    expect { eng.run_pipeline pipeline }.to raise_error(ArgumentError)
  end

  it '#run_pipeline runs triggers' do
    trigger = double(:trigger)
    allow(trigger).to receive(:full_tag).and_return(:'trigger.test_trigger')
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

    eng = Nanoci::Core::PipelineEngine.new(nil)
    eng.run_pipeline pipeline
  end

  it '#run_job schedule job execution on job_executor' do
    job_executor = double(:job_executor)
    expect(job_executor).to receive(:schedule_job_execution).with(
      :stage,
      :job,
      :inputs,
      :prev_inputs
    )
    eng = Nanoci::Core::PipelineEngine.new(job_executor)
    eng.run_job(:stage, :job, :inputs, :prev_inputs)
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

    eng = Nanoci::Core::PipelineEngine.new(nil)
    eng.run_pipeline(pipeline)

    pipeline_engine = double(:pipeline_engine)
    allow(pipeline_engine).to receive(:run_job)

    stage_a.run({ abc: 1 }, pipeline_engine)

    eng.job_complete(stage_a, job, { abc: 123 })

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

    eng = Nanoci::Core::PipelineEngine.new(nil)
    eng.run_pipeline(pipeline)
    job_b.state = Nanoci::Core::Job::State::RUNNING

    eng.job_complete(stage_a, job_a, { abc: 123 })

    expect(job_a.outputs).to include({ abc: 123 })
    expect(stage_a.outputs).to_not include({ abc: 123 })
  end
end
