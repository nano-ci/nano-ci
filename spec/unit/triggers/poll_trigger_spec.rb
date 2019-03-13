# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/definition/trigger_definition'
require 'nanoci/triggers/poll_trigger'

RSpec.describe Nanoci::Triggers::PollTrigger do
  it 'saves interval from src' do
    trigger_definition = Nanoci::Definition::PollTriggerDefinition.new(
      type: 'poll',
      interval: 5
    )
    trigger = Nanoci::Triggers::PollTrigger.new(nil, trigger_definition)
    expect(trigger.interval).to eq 5
  end

  it 'adds periodic timer with specified interval when run' do
    trigger_definition = Nanoci::Definition::PollTriggerDefinition.new(
      type: 'poll',
      interval: 5
    )
    trigger = Nanoci::Triggers::PollTrigger.new(nil, trigger_definition)
    event_machine = class_double(EventMachine).as_stubbed_const
    expect(event_machine).to receive(:add_periodic_timer).with(5)
    trigger.run(nil, nil, {})
  end

  it 'calls build_scheduler.trigger_build is repo.changes? returns true' do
    repo = double('repo')
    allow(repo).to receive(:changes?).and_return(true)
    allow(repo).to receive(:tag).and_return('abc')
    project = double('project')

    trigger_definition = Nanoci::Definition::PollTriggerDefinition.new(
      type: 'poll',
      interval: 5
    )
    trigger = Nanoci::Triggers::PollTrigger.new(repo, trigger_definition)
    event_machine = class_double(EventMachine).as_stubbed_const
    allow(event_machine).to receive(:add_periodic_timer).and_yield

    build_scheduler = double('build_scheduler')
    expect(build_scheduler).to receive(:trigger_build).with(project, trigger)

    trigger.run(build_scheduler, project, {})
  end

  it 'does not call project.trigger_build is repo.changes? returns false' do
    repo = double('repo')
    allow(repo).to receive(:changes?).and_return(false)
    allow(repo).to receive(:tag).and_return('abc')
    project = double('project')

    trigger_definition = Nanoci::Definition::PollTriggerDefinition.new(
      type: 'poll',
      interval: 5
    )
    trigger = Nanoci::Triggers::PollTrigger.new(repo, trigger_definition)
    event_machine = class_double(EventMachine).as_stubbed_const
    allow(event_machine).to receive(:add_periodic_timer).and_yield

    build_scheduler = double('build_scheduler')
    expect(build_scheduler).not_to receive(:trigger_build).with(project, trigger)

    trigger.run(build_scheduler, project, {})
  end

  it 'registers itself in resources map as trigger:poll' do
    expect(Nanoci.resources.get('trigger:poll')).to eq Nanoci::Triggers::PollTrigger
  end
end
