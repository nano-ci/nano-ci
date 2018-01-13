require 'spec_helper'

require 'nanoci/variable'

RSpec.describe Nanoci::Variable do
  it 'saves tag from src' do
    var = Nanoci::Variable.new('tag' => 'var1')
    expect(var.tag).to eq 'var1'
  end

  it 'saves value from src' do
    var = Nanoci::Variable.new('value' => 'value')
    expect(var.value).to eq 'value'
  end

  it 'expand throws error on cycle' do
    var = Nanoci::Variable.new('tag' => 'var1', 'value' => '${var1}')
    expect { var.expand({})}
      .to raise_error.with_message('Cycle in expanding variable var1')
  end

  it 'expands value with variables' do
    var1 = Nanoci::Variable.new('tag' => 'var1', 'value' => '${var2}')
    var2 = Nanoci::Variable.new('tag' => 'var1', 'value' => 'abc')
    expect(var1.expand('var2' => var2)).to eq 'abc'
  end
end
