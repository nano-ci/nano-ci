require 'spec_helper'

require 'nanoci/variable'

RSpec.describe Nanoci::Variable do
  it 'reads tag from src' do
    var = Nanoci::Variable.new(tag: 'var1')
    expect(var.tag).to eq 'var1'
  end

  it 'reads value from src' do
    var = Nanoci::Variable.new(value: 'value')
    expect(var.value).to eq 'value'
  end

  it 'expand throws error on cycle' do
    var = Nanoci::Variable.new(tag: 'var1', value: '${var1}')
    expect { var.expand({})}
      .to raise_error.with_message('Cycle in expanding variable var1')
  end

  it 'expands value with variables' do
    var1 = Nanoci::Variable.new(tag: 'var1', value: '${var2}')
    var2 = Nanoci::Variable.new(tag: 'var1', value: 'abc')
    expect(var1.expand('var2' => var2)).to eq 'abc'
  end

  it 'returns memento' do
    var1 = Nanoci::Variable.new(tag: 'var1', value: 'abc')
    memento = var1.memento
    expect(memento).to_not be_nil
    expect(memento[:tag]).to eq 'var1'
    expect(memento[:value]).to eq 'abc'
  end

  it 'restores from memento' do
    var1 = Nanoci::Variable.new(tag: 'var1', value: 'abc')
    memento = { tag: 'var1', value: 'def' }
    var1.memento = memento

    expect(var1.value).to eq 'def'
  end
end
