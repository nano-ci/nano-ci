# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/core/trigger'

# Test trigger class
class TestTrigger < Nanoci::Core::Trigger
  def invoke_pulse
    on_pulse
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

  it '#on_pulse invokes #pulse event' do
    trigger = TestTrigger.new(tag: :'test-trigger')

    sender = nil
    event_args = nil

    trigger.pulse.attach do |s, e|
      sender = s
      event_args = e
    end
    trigger.invoke_pulse
    expect(sender).to be trigger
    expect(event_args).to be_a(Nanoci::Core::TriggerPulseEventArgs)
  end

  it '#on_pulse sets event args properties' do
    trigger = TestTrigger.new(tag: :'test-trigger')

    event_args = nil

    trigger.pulse.attach do |_, e|
      event_args = e
    end
    trigger.invoke_pulse
    time_now = Time.now.utc.iso8601
    expect(event_args.trigger).to be(trigger)
    expect(event_args.outputs).to be_a(Hash)
    expect(event_args.outputs).to include(:'trigger.test-trigger.trigger_time')
    expect(event_args.outputs[:'trigger.test-trigger.trigger_time']).to eq(time_now)
  end

  it '#run does not throw errors' do
    trigger = Nanoci::Core::Trigger.new(tag: :trigger)
    expect { trigger.run }.to_not raise_error
  end
end
