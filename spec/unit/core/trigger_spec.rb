# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/trigger'

# Test trigger class
class TestTrigger < Nanoci::Core::Trigger
  def invoke_pulse
    pulse
  end
end

RSpec.describe Nanoci::Core::Trigger do
  it 'Trigger.item_type returns trigger' do
    expect(Nanoci::Core::Trigger.item_type).to eq 'trigger'
  end

  it '#initialize sets #tag' do
    trigger = Nanoci::Core::Trigger.new(tag: :'trigger-tag')
    expect(trigger.tag).to be :'trigger-tag'
  end

  it '#full_tag returns fully formatted tag' do
    trigger = Nanoci::Core::Trigger.new(tag: :'trigger-tag')
    expect(trigger.full_tag).to be :'trigger.trigger-tag'
  end

  it '#pulse returns outputs' do
    trigger = TestTrigger.new(tag: :'test-trigger')

    outputs = trigger.invoke_pulse
    time_now = Time.now.utc.iso8601
    expect(outputs).to be_a(Hash)
    expect(outputs).to include(:'trigger.test-trigger.trigger_time')
    expect(outputs[:'trigger.test-trigger.trigger_time']).to eq(time_now)
  end

  it '#run does not throw errors' do
    trigger = Nanoci::Core::Trigger.new(tag: :trigger)
    expect { trigger.run }.to_not raise_error
  end
end
