# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/dsl/job_dsl'

RSpec.describe Nanoci::DSL::JobDSL do
  it '#build return Nanoci::Core::Job' do
    job_dsl = Nanoci::DSL::JobDSL.new(nil, :job_tag, :stage_tag, :project_tag, work_dir: '/abc/def')
    job = job_dsl.build

    expect(job).to be_instance_of(Nanoci::Core::Job)
  end

  it '#build builds a Job with specified tag' do
    job_dsl = Nanoci::DSL::JobDSL.new(nil, :job_tag, :stage_tag, :project_tag, work_dir: nil)
    job = job_dsl.build

    expect(job.tag).to be(:job_tag)
  end

  it '#build builds a Job with specified work_dir' do
    job_dsl = Nanoci::DSL::JobDSL.new(nil, :job_tag, :stage_tag, :project_tag, work_dir: '/abc/def')
    job = job_dsl.build

    expect(job.work_dir).to be('/abc/def')
  end
end
