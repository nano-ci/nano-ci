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
    expect(pipe_dsl.projects).to include :prtag
  end

  it 'sets project tag to value from string' do
    str = %(
      project :prtag, 'test project' do
      end
    )
    pipe_dsl = Nanoci::DSL::ScriptDSL.from_string(str)

    expect(pipe_dsl.projects[:prtag].tag).to eq :prtag
  end

  it 'sets project tag to value from string' do
    str = %(
      project :prtag, 'test project' do
      end
    )
    pipe_dsl = Nanoci::DSL::ScriptDSL.from_string(str)

    expect(pipe_dsl.projects[:prtag].name).to eq 'test project'
  end
end
