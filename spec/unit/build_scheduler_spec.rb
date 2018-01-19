require 'spec_helper'

require 'nanoci/build'
require 'nanoci/build_scheduler'

RSpec.describe Nanoci::BuildScheduler do
  it 'stores build in builds collection when build is run' do
    build_scheduler = Nanoci::BuildScheduler.new(nil)
    build = double('build')

    build_scheduler.run_build(build)

    expect(build_scheduler.builds).to include build
  end

  it 'queued_builds returns array of builds in state QUEUED' do
    build_scheduler = Nanoci::BuildScheduler.new(nil)
    queued_build = double('queued_build')
    allow(queued_build).to receive(:state).and_return(Nanoci::Build::State::QUEUED)

    running_build = double('running_build')
    allow(running_build).to receive(:run)
    allow(running_build).to receive(:state).and_return(Nanoci::Build::State::RUNNING)

    build_scheduler.run_build(queued_build)
    build_scheduler.run_build(running_build)

    expect(build_scheduler.queued_builds).to include queued_build
    expect(build_scheduler.queued_builds).not_to include running_build
  end

  it 'queued_builds returns array of jobs in state QUEUED' do
    build_scheduler = Nanoci::BuildScheduler.new(nil)
    build = double('build')
    allow(build).to receive(:state)

    queued_job = double('queued_job')
    allow(queued_job).to receive(:state).and_return(Nanoci::Build::State::QUEUED)

    running_job = double('running_job')
    allow(running_job).to receive(:state).and_return(Nanoci::Build::State::RUNNING)

    stage = double('stage')
    allow(stage).to receive(:jobs).and_return([queued_job, running_job])

    allow(build).to receive(:current_stage).and_return(stage)

    expect(build_scheduler.queued_jobs(build)).to include queued_job
    expect(build_scheduler.queued_jobs(build)).not_to include running_job
  end

  it 'schedule_build runs scheduled jobs only on capable agents' do
    agent = double(agent)
    allow(agent).to receive(:run_job)

    agent_manager = double('agent_manager')
    allow(agent_manager).to receive(:find_agent).and_return(agent, nil)

    queued_job = double('queued_job')
    allow(queued_job).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(queued_job).to receive(:required_agent_capabilities)

    queued_unavailable_job = double('queued_unavailable_job')
    allow(queued_unavailable_job).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(queued_unavailable_job).to receive(:required_agent_capabilities)

    stage = double('stage')
    allow(stage).to receive(:jobs).and_return([queued_job])

    build = double('queued_build')
    allow(build).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(build).to receive(:current_stage).and_return(stage)

    build_scheduler = Nanoci::BuildScheduler.new(agent_manager)
    build_scheduler.schedule_build(build)

    expect(agent).to have_received(:run_job).with queued_job
    expect(agent).not_to have_received(:run_job).with queued_unavailable_job
  end

  it 'schedule_builds runs scheduled jobs only on capable agents' do
    agent = double(agent)
    allow(agent).to receive(:run_job)

    agent_manager = double('agent_manager')
    allow(agent_manager).to receive(:find_agent).and_return(agent, nil)

    queued_job = double('queued_job')
    allow(queued_job).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(queued_job).to receive(:required_agent_capabilities)

    queued_unavailable_job = double('queued_unavailable_job')
    allow(queued_unavailable_job).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(queued_unavailable_job).to receive(:required_agent_capabilities)

    stage = double('stage')
    allow(stage).to receive(:jobs).and_return([queued_job, queued_unavailable_job])

    build = double('queued_build')
    allow(build).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(build).to receive(:current_stage).and_return(stage)

    build_scheduler = Nanoci::BuildScheduler.new(agent_manager)
    build_scheduler.run_build(build)
    build_scheduler.schedule_builds

    expect(agent).to have_received(:run_job).with queued_job
    expect(agent).not_to have_received(:run_job).with queued_unavailable_job
  end

  it 'adds periodic timer when run' do
    event_machine = class_double(EventMachine).as_stubbed_const
    expect(event_machine).to receive(:add_periodic_timer).with(5)

    build_scheduler = Nanoci::BuildScheduler.new(nil)
    build_scheduler.run(5)
  end

  it 'shedules build when timer fires' do
    agent = double(agent)
    allow(agent).to receive(:run_job)

    agent_manager = double('agent_manager')
    allow(agent_manager).to receive(:find_agent).and_return(agent)

    queued_job = double('queued_job')
    allow(queued_job).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(queued_job).to receive(:required_agent_capabilities)

    stage = double('stage')
    allow(stage).to receive(:jobs).and_return([queued_job])

    build = double('queued_build')
    allow(build).to receive(:run)
    allow(build).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(build).to receive(:current_stage).and_return(stage)

    build_scheduler = Nanoci::BuildScheduler.new(agent_manager)
    build_scheduler.run_build(build)

    event_machine = class_double(EventMachine).as_stubbed_const
    allow(event_machine).to receive(:add_periodic_timer).and_yield

    build_scheduler.run(1)

    expect(agent).to have_received(:run_job).with queued_job
  end
end
