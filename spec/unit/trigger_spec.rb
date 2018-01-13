require 'spec_helper'

require 'nanoci/trigger'

RSpec.describe Nanoci::Trigger do
  it 'saves type to a property' do
    trigger = Nanoci::Trigger.new('type' => 'polling')
    expect(trigger.type).to eq 'polling'
  end
end
