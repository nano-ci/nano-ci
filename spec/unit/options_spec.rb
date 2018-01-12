require 'spec_helper'

require 'nanoci/options'

RSpec.describe Nanoci::Options do
  it 'reads --config value' do
    options = Nanoci::Options.parse(['--config', 'abc', '--project', 'def'])
    expect(options.config).to eq 'abc'
  end

  it 'reads --project value' do
    options = Nanoci::Options.parse(['--config', 'abc', '--project', 'def'])
    expect(options.project).to eq File.expand_path('def')
  end

  it 'requres --project value' do
    output = capture_stderr do
      expect { Nanoci::Options.parse(['--config', 'abc']) }.to raise_error(SystemExit)
    end
    expect(output).to include '--project is requried'
  end
end
