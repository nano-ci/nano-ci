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
    trigger.run(nil)
  end

  it 'calls build_scheduler.trigger_build is repo.detect_changes returns true' do
    repo = double('repo')
    allow(repo).to receive(:detect_changes).and_return(true)
    allow(repo).to receive(:tag).and_return('abc')
    project = double('project')

    trigger = Nanoci::Triggers::PollTrigger.new(repo, project, 'interval' => 5)
    event_machine = class_double(EventMachine).as_stubbed_const
    allow(event_machine).to receive(:add_periodic_timer).and_yield

    build_scheduler = double('build_scheduler')
    expect(build_scheduler).to receive(:trigger_build).with(project, trigger)

    trigger.run(build_scheduler)
  end

  it 'does not call project.trigger_build is repo.detect_changes returns false' do
    repo = double('repo')
    allow(repo).to receive(:detect_changes).and_return(false)
    allow(repo).to receive(:tag).and_return('abc')
    project = double('project')

    trigger = Nanoci::Triggers::PollTrigger.new(repo, project, 'interval' => 5)
    event_machine = class_double(EventMachine).as_stubbed_const
    allow(event_machine).to receive(:add_periodic_timer).and_yield

    build_scheduler = double('build_scheduler')
    expect(build_scheduler).not_to receive(:trigger_build).with(project, trigger)

    trigger.run(build_scheduler)
  end
end
