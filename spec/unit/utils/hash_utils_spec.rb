# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/utils/hash_utils'

RSpec.describe Hash do
  describe 'symbolize_keys' do
    it 'symbolize_keys conver string key to symbol' do
      hash = { 'abc' => 'def' }.symbolize_keys
      expect(hash).to include :abc
      expect(hash).not_to include 'abc'
    end

    it 'does not change non-string keys' do
      hash = { 0 => '123', :abc => 'def' }.symbolize_keys
      expect(hash).to include 0
      expect(hash).to include :abc
    end

    it 'recusively symbolizes hashes in values' do
      hash = { 'abc' => { 'def' => 'fgh' } }.symbolize_keys
      expect(hash).to include :abc
      expect(hash[:abc]).to be_a Hash
      expect(hash[:abc]).to include :def
    end

    it 'recursively symbolizes hashes in arrays' do
      hash = {
        'abc' => [{
          'def' => 'fgh'
        }]
      }.symbolize_keys
      expect(hash[:abc]).to be_a Array
      expect(hash[:abc][0]).to include :def
    end
  end

  describe 'flatten_hash_value' do
    it 'symbolizes keys' do
      hash = { 'abc' => 'def' }.flatten_hash_value
      expect(hash).to include abc: 'def'
      expect(hash).not_to include 'abc'
    end

    it 'recursively flattens hashes' do
      hash = {
        'abc' => {
          'def' => 123
        },
        'def' => 345
      }.flatten_hash_value
      expect(hash).to include 'abc.def': 123
      expect(hash).to include def: 345
    end
  end
end
