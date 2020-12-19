# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/dsl/script_dsl'

RSpec.describe Nanoci::DSL::ScriptDSL do
  it 'reads string with primitive project definition' do
    str = %(
      project :prtag, 'test project' do
      end
    )
    pipe_dsl = Nanoci::DSL::ScriptDSL.from_string(str)
    expect(pipe_dsl).not_to be nil
    expect(pipe_dsl.projects.length).to eq 1
    pr_def = pipe_dsl.projects[0].build
    expect(pr_def[:tag]).to eq :prtag
  end

  it 'sets project name to value from string' do
    str = %(
      project :prtag, 'test project' do
      end
    )
    pipe_dsl = Nanoci::DSL::ScriptDSL.from_string(str)

    pr_def = pipe_dsl.projects[0].build
    expect(pr_def[:name]).to eq 'test project'
  end
end
