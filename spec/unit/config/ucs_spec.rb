# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/config/ucs'

RSpec.describe Nanoci::Config::UCS do
  describe 'parse_argv' do
    it 'parses valid config option' do
      argv = Nanoci::Config::UCS.parse_argv(['--config.a=abc'])
      expect(argv).to be_a Hash
      expect(argv).to include 'config.a': 'abc'
    end

    it 'raise error on missing double dash' do
      expect do
        Nanoci::Config::UCS.parse_argv(['config.a=abc'])
      end.to raise_error('invalid option config.a=abc - does not start with --')
    end

    it 'raise error on missing equal' do
      expect do
        Nanoci::Config::UCS.parse_argv(['--config.a abc'])
      end.to raise_error('invalid option --config.a abc - does not have = to split key and value')
    end
  end
end
