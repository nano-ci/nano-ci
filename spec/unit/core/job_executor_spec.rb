# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/job_executor'

# JobExecutor implementation for tests
class TestJobExecutor < Nanoci::Core::JobExecutor
  def raise_publish(stage, job, outputs)
    publish(stage, job, outputs)
  end
end

RSpec.describe Nanoci::Core::JobExecutor do
  it '#schedule_job_execution raises error NotImplementedError' do
    executor = Nanoci::Core::JobExecutor.new(nil)
    expect { executor.schedule_job_execution(nil, nil, nil, nil, nil) }.to raise_error RuntimeError
  end

  it '#publish raises event job_complete' do
    executor = TestJobExecutor.new(nil)

    sender = nil
    event_args = nil

    executor.job_complete.attach do |s, e|
      sender = s
      event_args = e
    end

    executor.raise_publish(:stage, :job, :outputs)

    expect(sender).to be executor
    expect(event_args).to be_a(Nanoci::Core::JobCompleteEventArgs)
    expect(event_args.stage).to eq(:stage)
    expect(event_args.job).to eq(:job)
    expect(event_args.outputs).to eq(:outputs)
  end
end
