require 'spec_helper'

require 'nanoci/trigger'

RSpec.describe Nanoci::Trigger do
  it 'saves type to a property' do
    trigger = Nanoci::Trigger.new(nil, nil, 'type' => 'polling')
    expect(trigger.type).to eq 'polling'
  end

  it 'calls build_scheduler.trigger_build is repo.changes? returns true' do
    repo = double('repo')
    allow(repo).to receive(:changes?).and_return(true)
    allow(repo).to receive(:tag).and_return('abc')
    project = double('project')

    trigger = Nanoci::Trigger.new(repo, project, 'interval' => 5)

    build_scheduler = double('build_scheduler')
    expect(build_scheduler).to receive(:trigger_build).with(project, trigger)

    trigger.run(build_scheduler, {})
    trigger.trigger_build
  end

  it 'does not call project.trigger_build is repo.changes? returns false' do
    repo = double('repo')
    allow(repo).to receive(:changes?).and_return(false)
    allow(repo).to receive(:tag).and_return('repo')
    project = double('project')

    trigger = Nanoci::Trigger.new(repo, project, 'interval' => 5)

    build_scheduler = double('build_scheduler')
    expect(build_scheduler).not_to receive(:trigger_build).with(project, trigger)

    trigger.run(build_scheduler, {})
    trigger.trigger_build
  end
end
