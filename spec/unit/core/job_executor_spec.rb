# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/job_executor'

# JobExecutor implementation for tests
class TestJobExecutor < Nanoci::Core::JobExecutor
  def raise_publish(project, stage, job, outputs)
    job_succeeded(project, stage, job, outputs)
  end
end

RSpec.describe Nanoci::Core::JobExecutor do
  it '#schedule_job_execution tracks running job' do
    executor = Nanoci::Core::JobExecutor.new(nil, nil)
    project = double(:project)
    allow(project).to receive(:tag).and_return(:project)
    stage = double(:stage)
    allow(stage).to receive(:tag).and_return(:stage)
    job = double(:job)
    allow(job).to receive(:tag).and_return(:job)
    executor.schedule_job_execution(project, stage, job, nil, nil)
    expect(executor.job_running?(project.tag, stage.tag, job.tag)).to be true
  end

  it '#publish raises event job_complete' do
    topic = double(:topic)
    executor = TestJobExecutor.new(nil, topic)

    project = double(:project)
    allow(project).to receive(:tag).and_return(:project)

    stage = double(:stage)
    allow(stage).to receive(:tag).and_return(:stage)

    job = double(:job)
    allow(job).to receive(:tag).and_return(:job)

    expect(topic).to receive(:publish) do |m|
      expect(m).to be_a(Nanoci::Core::Messages::JobCompleteMessage)
      expect(m.project_tag).to eq(:project)
      expect(m.stage_tag).to eq(:stage)
      expect(m.job_tag).to eq(:job)
      expect(m.outputs).to eq(:outputs)
    end

    executor.raise_publish(project, stage, job, :outputs)
  end
end
