require 'spec_helper'

require 'nanoci/triggers/poll_trigger'

RSpec.describe Nanoci::Triggers::PollTrigger do
  it 'saves interval from src' do
    trigger = Nanoci::Triggers::PollTrigger.new(nil, nil, 'interval' => 5)
    expect(trigger.interval).to eq 5
  end

  it 'saves schedule from src' do
    trigger = Nanoci::Triggers::PollTrigger.new(nil, nil, 'schedule' => '*')
    expect(trigger.schedule).to eq '*'
  end

  it 'adds periodic timer with specified interval when run' do
    trigger = Nanoci::Triggers::PollTrigger.new(nil, nil, 'interval' => 5)
    event_machine = class_double(EventMachine).as_stubbed_const
    expect(event_machine).to receive(:add_periodic_timer).with(5)
    trigger.run
  end
end
