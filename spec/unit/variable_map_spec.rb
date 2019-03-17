# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/variable_map'

RSpec.describe Nanoci::VariableMap do
  describe '#initialize' do
    it 'raises an error on unsupported data type' do
      expect { Nanoci::VariableMap.new('data') }
        .to raise_error 'unsupported type'
    end

    it 'initializes map from passed VariableMap' do
      map = Nanoci::VariableMap.new
      map[:variable] = 'abc'
      copied_map = Nanoci::VariableMap.new(map)
      expect(copied_map).to include(variable: 'abc')
    end

    it 'initializes map from hash with scalar value' do
      map = Nanoci::VariableMap.new(variable: 'abc')
      expect(map).to include(variable: 'abc')
    end

    it 'initializes map from hash with Variable value' do
      var = Nanoci::Variable.new(:variable, 'abc')
      map = Nanoci::VariableMap.new(variable: var)
      expect(map).to include(variable: 'abc')
    end

    it 'raises an error if hash key is not a Symbol' do
      hash = { '123' => '456' }
      expect { Nanoci::VariableMap.new(hash) }
        .to raise_error 'hash key is not a Symbol'
    end
  end

  describe '#[]' do
    it 'returns nil if variable is not present' do
      map = Nanoci::VariableMap.new
      expect(map[:var]).to be_nil
    end

    it 'raises error if key is not a Symbol' do
      map = Nanoci::VariableMap.new
      expect { map['abc'] }.to raise_error('key is not a Symbol')
    end

    it 'returns Nanoci::Variable is variable is present' do
      map = Nanoci::VariableMap.new(var: 'abc')
      var = map[:var]
      expect(var).to be_a(Nanoci::Variable)
      expect(var.tag).to eq(:var)
      expect(var.value).to eq('abc')
    end
  end

  describe '#[]=' do
    it 'raises error if key is not a Symbol' do
      map = Nanoci::VariableMap.new
      expect { map['abc'] = 0 }.to raise_error('key is not a Symbol')
    end

    it 'does not raize error if key is a Symbol' do
      map = Nanoci::VariableMap.new
      expect { map[:abc] = 0 }.to_not raise_error
    end

    it 'creates a new variable from scalar value' do
      map = Nanoci::VariableMap.new
      map[:key] = 'value'
      expect(map[:key]).to be_a(Nanoci::Variable)
      expect(map[:key].value).to eq 'value'
    end

    it 'creates a new variable from Variable' do
      map = Nanoci::VariableMap.new
      var_def = Nanoci::Definition::VariableDefinition.new(key: 'value')
      var = Nanoci::Variable.new(var_def)
      map[:key] = var
      expect(map[:key]).to be_a(Nanoci::Variable)
      expect(map[:key].value).to eq 'value'
    end

    it 'updates a value of existing variable from scalar value' do
      map = Nanoci::VariableMap.new(key: 'value')
      map[:key] = 'value2'
      expect(map[:key]).to be_a(Nanoci::Variable)
      expect(map[:key].value).to eq 'value2'
    end

    it 'updates a value of existing variable from Variable' do
      map = Nanoci::VariableMap.new(key: 'value')
      var_def = Nanoci::Definition::VariableDefinition.new(key: 'value2')
      var = Nanoci::Variable.new(var_def)
      map[:key] = var
      expect(map[:key]).to be_a(Nanoci::Variable)
      expect(map[:key].value).to eq 'value2'
    end
  end

  describe '#to_hash' do
    it 'returns a hash with map content' do
      map = Nanoci::VariableMap.new(key: 'value')
      hash = map.to_hash
      expect(hash).to include :key
      expect(hash[:key].value).to eq 'value'
    end
  end
end
