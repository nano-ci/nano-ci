# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/job'

RSpec.describe Nanoci::Job do
  it 'reads tag from definition' do
    job = Nanoci::Job.new(tag: 'build-job', block: nil)
    expect(job.tag).to eq :'build-job'
  end
end
