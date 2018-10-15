# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/definition/variable_definition'
require 'nanoci/variable'

RSpec.describe Nanoci::Variable do
  it 'reads tag from src' do
    var_def = Nanoci::Definition::VariableDefinition.new(
      var1: true
    )
    var = Nanoci::Variable.new(var_def)
    expect(var.tag).to eq :var1
  end

  it 'reads value from src' do
    var_def = Nanoci::Definition::VariableDefinition.new(
      var1: 'value'
    )
    var = Nanoci::Variable.new(var_def)
    expect(var.value).to eq 'value'
  end

  it 'expand throws error on cycle' do
    var_def = Nanoci::Definition::VariableDefinition.new(
      var1: '${var1}'
    )
    var = Nanoci::Variable.new(var_def)
    expect { var.expand({}) }
      .to raise_error.with_message('Cycle in expanding variable var1')
  end

  it 'expands value with variables' do
    var1_def = Nanoci::Definition::VariableDefinition.new(
      var1: '${var2}'
    )
    var2_def = Nanoci::Definition::VariableDefinition.new(
      var2: 'abc'
    )
    var1 = Nanoci::Variable.new(var1_def)
    var2 = Nanoci::Variable.new(var2_def)
    expect(var1.expand('var2' => var2)).to eq 'abc'
  end

  it 'returns memento' do
    var_def = Nanoci::Definition::VariableDefinition.new(
      var1: 'abc'
    )
    var1 = Nanoci::Variable.new(var_def)
    memento = var1.memento
    expect(memento).to_not be_nil
    expect(memento[:tag]).to eq :var1
    expect(memento[:value]).to eq 'abc'
  end

  it 'restores from memento' do
    var_def = Nanoci::Definition::VariableDefinition.new(
      var1: 'value'
    )
    var1 = Nanoci::Variable.new(var_def)
    memento = { tag: :var1, value: 'def' }
    var1.memento = memento

    expect(var1.value).to eq 'def'
  end
end
