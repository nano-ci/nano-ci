# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/job_executor'

# JobExecutor implementation for tests
class TestJobExecutor < Nanoci::Core::JobExecutor
  def raise_publish(job, outputs)
    job_succeeded(job, outputs)
  end
end

RSpec.describe Nanoci::Core::JobExecutor do
  it '#schedule_job_execution tracks running job' do
    executor = Nanoci::Core::JobExecutor.new(nil)
    project = double(:project)
    allow(project).to receive(:tag).and_return(:project)
    stage = double(:stage)
    allow(stage).to receive(:tag).and_return(:stage)
    job = double(:job)
    allow(job).to receive(:tag).and_return(:job)
    allow(job).to receive(:full_tag).and_return(:job)
    allow(job).to receive(:project).and_return(project)
    allow(job).to receive(:stage).and_return(stage)
    executor.schedule_job_execution(job, nil, nil)
    expect(executor.job_running?(job)).to be true
  end

  it '#publish raises event job_complete' do
    executor = TestJobExecutor.new(nil)

    project = double(:project)
    allow(project).to receive(:tag).and_return(:project)

    stage = double(:stage)
    allow(stage).to receive(:tag).and_return(:stage)

    job = double(:job)
    allow(job).to receive(:tag).and_return(:job)
    allow(job).to receive(:full_tag).and_return(:full_tag)

    executor.schedule_job_execution(job, {}, {})
    executor.raise_publish(job, :outputs)

    expect(executor.completed_jobs?).to be true
    jr = executor.pull_completed_job
    expect(jr.state).to eq(Nanoci::Core::Job::State::SUCCESSFUL)
  end
end
