# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/job'
require 'nanoci/core/job_state'

RSpec.describe Nanoci::Core::Job do
  it '#initialize sets tag' do
    job = Nanoci::Core::Job.new(tag: 'build-job', body: nil)
    expect(job.tag).to eq :'build-job'
  end

  it '#initialize sets work_dir' do
    job = Nanoci::Core::Job.new(tag: 'build-job', body: nil, work_dir: 'local')
    expect(job.work_dir).to eq 'local'
  end

  it '#initialize sets initial state to IDLE' do
    job = Nanoci::Core::Job.new(tag: 'build-job', body: nil, work_dir: 'local')
    expect(job.state).to eq Nanoci::Core::Job::State::IDLE
  end

  it '#validate raises error if tag is nil' do
    job = Nanoci::Core::Job.new(tag: nil, body: nil, work_dir: nil)
    expect { job.validate }.to raise_error(ArgumentError)
  end

  it '#validate raises error if body is nil' do
    job = Nanoci::Core::Job.new(tag: 'build-job', body: nil, work_dir: nil)
    expect { job.validate }.to raise_error(ArgumentError)
  end

  it '#validate raises error if body is not a proc' do
    job = Nanoci::Core::Job.new(tag: 'build-job', body: 'abc', work_dir: nil)
    expect { job.validate }.to raise_error(ArgumentError)
  end

  it '#validate pass if body is a proc' do
    job = Nanoci::Core::Job.new(tag: 'build-job', body: -> { 'abc' }, work_dir: nil)
    expect { job.validate }.to_not raise_error
  end

  it '#stage= raises error if value is not valid' do
    job = Nanoci::Core::Job.new(tag: 'build-job', body: 'abc', work_dir: nil)
    expect { job.state = 'abc' }.to raise_error(ArgumentError, 'invalid state abc')
  end

  it '#stage= sets valid value' do
    job = Nanoci::Core::Job.new(tag: 'build-job', body: 'abc', work_dir: nil)
    job.state = Nanoci::Core::Job::State::RUNNING
    expect(job.state).to eq Nanoci::Core::Job::State::RUNNING
  end
end
