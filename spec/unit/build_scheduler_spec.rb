require 'spec_helper'

require 'nanoci/build'
require 'nanoci/build_scheduler'
require 'nanoci/config/ucs'

RSpec.describe Nanoci::BuildScheduler do
  before(:example) do
    Nanoci::Config::UCS.initialize(nil, nil)
    Nanoci::Config::UCS.instance.override(Nanoci::Config::AgentConfig::BUILD_DATA_DIR, "")
  end

  after(:example) do
    Nanoci::Config::UCS.destroy
  end

  it 'stores build in builds collection when build is run' do
    state_manager = double('state_manager')
    allow(state_manager).to receive(:put_state)
    build_scheduler = Nanoci::BuildScheduler.new(nil, state_manager)
    build = double('build')
    allow(build).to receive(:memento)

    build_scheduler.run_build(build)

    expect(build_scheduler.builds).to include build
  end

  it 'queued_builds returns array of builds in state QUEUED' do
    state_manager = double('state_manager')
    allow(state_manager).to receive(:put_state)
    build_scheduler = Nanoci::BuildScheduler.new(nil, state_manager)
    queued_build = double('queued_build')
    allow(queued_build).to receive(:memento)
    allow(queued_build).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(queued_build).to receive(:tag).and_return('abc-1')

    running_build = double('running_build')
    allow(running_build).to receive(:memento)
    allow(running_build).to receive(:run)
    allow(running_build).to receive(:state).and_return(Nanoci::Build::State::RUNNING)
    allow(running_build).to receive(:tag).and_return('abc-1')

    build_scheduler.run_build(queued_build)
    build_scheduler.run_build(running_build)

    expect(build_scheduler.queued_builds).to include queued_build
    expect(build_scheduler.queued_builds).not_to include running_build
  end

  it 'queued_builds returns array of jobs in state QUEUED' do
    state_manager = double('state_manager')
    allow(state_manager).to receive(:put_state)
    build_scheduler = Nanoci::BuildScheduler.new(nil, state_manager)
    build = double('build')
    allow(build).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(build).to receive(:memento)

    queued_job = double('queued_job')
    allow(queued_job).to receive(:state).and_return(Nanoci::Build::State::QUEUED)

    running_job = double('running_job')
    allow(running_job).to receive(:state).and_return(Nanoci::Build::State::RUNNING)

    stage = double('stage')
    allow(stage).to receive(:jobs).and_return([queued_job, running_job])

    allow(build).to receive(:current_stage).and_return(stage)
    allow(build).to receive(:stages).and_return([stage])

    build_scheduler.run_build(build)

    expect(build_scheduler.queued_jobs).to include queued_job
    expect(build_scheduler.queued_jobs).not_to include running_job
  end

  it 'schedule_job runs scheduled jobs only on capable agents' do
    agent = double(agent)
    allow(agent).to receive(:run_job)

    agent_manager = double('agent_manager')
    allow(agent_manager).to receive(:find_agent).and_return(agent, nil)

    build = double('queued_build')

    queued_job = double('queued_job')
    allow(queued_job).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(queued_job).to receive(:state=)
    allow(queued_job).to receive(:required_agent_capabilities)
    allow(queued_job).to receive(:tag).and_return('abc-1-def')
    allow(queued_job).to receive(:build).and_return(build)

    queued_unavailable_job = double('queued_unavailable_job')
    allow(queued_unavailable_job).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(queued_unavailable_job).to receive(:required_agent_capabilities)
    allow(queued_unavailable_job).to receive(:tag).and_return('abc-1-def')
    allow(queued_unavailable_job).to receive(:build).and_return(build)

    stage = double('stage')
    allow(stage).to receive(:jobs).and_return([queued_job])

    allow(build).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(build).to receive(:current_stage).and_return(stage)
    allow(build).to receive(:tag).and_return('abc-1')
    allow(build).to receive(:memento)

    state_manager = double('state_manager')
    allow(state_manager).to receive(:put_state)
    build_scheduler = Nanoci::BuildScheduler.new(agent_manager, state_manager)

    build_scheduler.schedule_job(queued_job)
    expect(agent).to have_received(:run_job).with(build, queued_job)

    build_scheduler.schedule_job(queued_unavailable_job)
    expect(agent).not_to have_received(:run_job).with(build, queued_unavailable_job)
  end

  it 'schedule_builds runs scheduled jobs only on capable agents' do
    agent = double(agent)
    allow(agent).to receive(:run_job)

    agent_manager = double('agent_manager')
    allow(agent_manager).to receive(:find_agent).and_return(agent, nil)

    build = double('queued_build')

    queued_job = double('queued_job')
    allow(queued_job).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(queued_job).to receive(:state=)
    allow(queued_job).to receive(:required_agent_capabilities)
    allow(queued_job).to receive(:tag).and_return('abc-1-def')
    allow(queued_job).to receive(:build).and_return(build)

    queued_unavailable_job = double('queued_unavailable_job')
    allow(queued_unavailable_job).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(queued_unavailable_job).to receive(:required_agent_capabilities)
    allow(queued_unavailable_job).to receive(:tag).and_return('abc-1-def')
    allow(queued_unavailable_job).to receive(:build).and_return(build)

    stage = double('stage')
    allow(stage).to receive(:jobs).and_return([queued_job, queued_unavailable_job])

    allow(build).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(build).to receive(:current_stage).and_return(stage)
    allow(build).to receive(:stages).and_return([stage])
    allow(build).to receive(:tag).and_return('abc-1')
    allow(build).to receive(:memento)

    state_manager = double('state_manager')
    allow(state_manager).to receive(:put_state)
    build_scheduler = Nanoci::BuildScheduler.new(agent_manager, state_manager)
    build_scheduler.run_build(build)
    build_scheduler.schedule_builds

    expect(agent).to have_received(:run_job).with(build, queued_job)
    expect(agent).not_to have_received(:run_job).with(build, queued_unavailable_job)
  end

  it 'adds periodic timer when run' do
    timer = double('timer')
    expect(timer).to receive(:execute)
    timer_task = class_double(Concurrent::TimerTask).as_stubbed_const
    expect(timer_task).to receive(:new)
      .with(execution_interval: 5)
      .and_return(timer)

    state_manager = double('state_manager')
    allow(state_manager).to receive(:put_state)
    build_scheduler = Nanoci::BuildScheduler.new(nil, state_manager)
    build_scheduler.run(5)
  end

  it 'shedules build when timer fires' do
    agent = double(agent)
    allow(agent).to receive(:run_job)

    agent_manager = double('agent_manager')
    allow(agent_manager).to receive(:find_agent).and_return(agent)

    build = double('queued_build')

    queued_job = double('queued_job')
    allow(queued_job).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    expect(queued_job).to receive(:state=).with(Nanoci::Build::State::PENDING)
    allow(queued_job).to receive(:required_agent_capabilities)
    allow(queued_job).to receive(:build).and_return(build)
    allow(queued_job).to receive(:tag).and_return('abc-1-def')

    stage = double('stage')
    allow(stage).to receive(:jobs).and_return([queued_job])

    allow(build).to receive(:run)
    allow(build).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(build).to receive(:current_stage).and_return(stage)
    allow(build).to receive(:stages).and_return([stage])
    allow(build).to receive(:tag).and_return('abc-1')
    allow(build).to receive(:memento)

    state_manager = double('state_manager')
    allow(state_manager).to receive(:put_state)
    build_scheduler = Nanoci::BuildScheduler.new(agent_manager, state_manager)
    build_scheduler.run_build(build)

    timer = double('timer')
    expect(timer).to receive(:execute)
    timer_callback = nil
    timer_task = class_double(Concurrent::TimerTask).as_stubbed_const
    allow(timer_task).to receive(:new) do |&block|
      timer_callback = block
      timer
    end

    build_scheduler.run(1)
    timer_callback.call

    expect(agent).to have_received(:run_job).with(build, queued_job)
  end

  it 'does not triggers multiple builds for the same project' do
    state_manager = double('state_manager')
    allow(state_manager).to receive(:put_state)
    build_scheduler = Nanoci::BuildScheduler.new(nil, state_manager)
    project = double('project')
    allow(project).to receive(:tag).and_return 'project-abc'
    allow(project).to receive(:variables).and_return({})
    queued_job = double('queued_job')
    allow(queued_job).to receive(:state).and_return(Nanoci::Build::State::QUEUED)
    allow(queued_job).to receive(:required_agent_capabilities)
    allow(queued_job).to receive(:tag).and_return('abc-1-def')

    stage = double('stage')
    allow(stage).to receive(:jobs).and_return([queued_job])
    allow(stage).to receive(:tag)

    allow(project).to receive(:stages).and_return([stage])
    allow(project).to receive(:repos).and_return({})
    allow(project).to receive(:state)

    build_scheduler.trigger_build(project, nil)
    build_scheduler.trigger_build(project, nil)

    expect(build_scheduler.builds.length).to eq 1
  end

  it 'cancels execution of pending job if agent did not start on time' do
    state_manager = double('state_manager')
    allow(state_manager).to receive(:put_state)

    project = double('project')
    allow(project).to receive(:tag).and_return 'project-abc'
    allow(project).to receive(:variables).and_return({})
    queued_job = double('queued_job')
    allow(queued_job).to receive(:required_agent_capabilities)
    allow(queued_job).to receive(:tag).and_return('abc-1-def')

    stage = double('stage')
    allow(stage).to receive(:jobs).and_return([queued_job])
    allow(stage).to receive(:tag)

    allow(project).to receive(:stages).and_return([stage])
    allow(project).to receive(:repos).and_return({})
    allow(project).to receive(:state)

    pending_job_timeout = 15

    agent_manager = double('agent_manager')
    agent = double('agent')
    allow(agent_manager).to receive(:find_agent).and_return(agent)
    expect(agent_manager).to receive(:timedout_agents).with(pending_job_timeout).and_return([agent])
    expect(agent).to receive(:run_job).with(kind_of(Nanoci::Build), kind_of(Nanoci::BuildJob))
    expect(agent).to receive(:cancel_job)

    Nanoci::Config::UCS.instance.override(Nanoci::Config::ServiceConfig::PENDING_JOB_TIMEOUT, 15)

    build_scheduler = Nanoci::BuildScheduler.new(agent_manager, state_manager)

    timer = double('timer')
    expect(timer).to receive(:execute)
    timer_callback = nil
    timer_task = class_double(Concurrent::TimerTask).as_stubbed_const
    allow(timer_task).to receive(:new) do |&block|
      timer_callback = block
      timer
    end

    build_scheduler.run(1)

    build_scheduler.trigger_build(project, nil)

    timer_callback.call
  end
end
