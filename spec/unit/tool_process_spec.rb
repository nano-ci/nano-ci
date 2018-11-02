# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/tool_process'

RSpec.describe Nanoci::ToolError do
  it 'expands env variables' do
    env = { var1: '${var2}' }
    vars = { var2: 'abc' }

    tool_process = Nanoci::ToolProcess.new('abc', env: env, vars: vars)
    expect(tool_process.env).to include(var1: 'abc')
  end
end
