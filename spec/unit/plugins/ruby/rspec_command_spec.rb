# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/plugins/ruby/ruby_plugin'

RSpec.describe Nanoci::Plugins::Ruby::RSpecCommand do
  it '#format_command formats command when no filter and no args' do
    command = Nanoci::Plugins::Ruby::RSpecCommand.new(nil, nil)
    expect(command.send(:format_command, nil, {})).to eq 'rspec'
  end

  it '#format_command formats command with passed filter' do
    command = Nanoci::Plugins::Ruby::RSpecCommand.new(nil, nil)
    filter = 'path/to/a_spec.rb[1:5,1:6]'
    opts = {}
    expected = 'rspec path/to/a_spec.rb[1:5,1:6]'
    expect(command.send(:format_command, filter, opts)).to eq expected
  end

  it '#format_command formats command with passed filter and opts' do
    command = Nanoci::Plugins::Ruby::RSpecCommand.new(nil, nil)
    filter = 'path/to/a_spec.rb[1:5,1:6]'
    opts = '--require file.rb'
    expected = 'rspec path/to/a_spec.rb[1:5,1:6] --require file.rb'
    expect(command.send(:format_command, filter, opts)).to eq expected
  end
end
