# frozen_string_literal: true

require 'logging'

require 'nanoci'
require 'nanoci/build'
require 'nanoci/config/ucs'
require 'nanoci/event_engine'
require 'nanoci/events/service_events'
require 'nanoci/state_manager'

module Nanoci
  # Build scheduler maintains queue of jobs
  # and schedules job execution on build agents
  class BuildScheduler
    include Logging.globally

    attr_accessor :builds

    # Initializes new instnance of [BuildScheduler]
    # @param agents_manager [Nanoci::AgentsManager]
    # @param state_manager [Nanoci::StateManager]
    # @param event_engine [Nanoci::EventEngine]
    def initialize(agents_manager, state_manager, event_engine)
      # @type [AgentManager]
      @agents_manager = agents_manager
      # @type [Nanoci::StateManager]
      @state_manager = state_manager
      @builds = []
      # @type [Nanoci::EventEngine]
      @event_engine = event_engine
      @event_engine.register(
        Events::SCHEDULE_BUILDS => method(:schedule_builds),
        Events::FINALIZE_BUILDS => method(:finalize_builds),
        Events::CANCEL_PENDING_JOBS => method(:cancel_timedout_pending_jobs)
      )
    end

    def start_new_build(project, trigger)
      build = Nanoci::Build.run(project, trigger, Config::UCS.instance.env)
      @state_manager.put_state(StateManager::Types::PROJECT, project.state)
      logger.info "a new build #{build.tag} triggered by #{trigger}"
      build
    rescue StandardError => e
      logger.error "failed to run a new build for project #{project.tag}"
      logger.error e
      nil
    end

    def trigger_build(project, trigger)
      if duplicate_build?(project.tag)
        logger.warn "cannot start another build for the project #{project.tag}"
      else
        trigger_new_build(project, trigger)
      end
    end

    def trigger_new_build(project, trigger)
      build = start_new_build(project, trigger)

      # build was not started due to error, exit
      return if build.nil?

      if build.current_stage.nil?
        logger.warn "build #{build.tag} has no runnable jobs"
      else
        run_build(build)
      end
    end

    def duplicate_build?(project_tag)
      builds.any? { |x| x.project.tag == project_tag }
    end

    def run_build(build)
      builds.push(build)
      @state_manager.put_state(StateManager::Types::BUILD, build.memento)
    end

    def run(interval)
      logger.info 'running BuildScheduler'

      @timer = Concurrent::TimerTask.new(execution_interval: interval) do
        @event_engine.post(Events::SCHEDULE_BUILDS)
        @event_engine.post(Events::FINALIZE_BUILDS)
        @event_engine.post(Events::CANCEL_PENDING_JOBS)
      end
      @timer.execute

      @event_engine.run
    end

    def finalize_builds
      finished_builds.each do |build|
        begin
          build.complete
          @state_manager.put_state(StateManager::Types::BUILD, build.memento)
          build.project.build_number = build.number
          @state_manager.put_state(StateManager::Types::PROJECT, build.project.state)
          @builds.delete build
          logger.info "finished build #{build.tag} in state #{Build::State.to_sym(build.state)}"
        rescue StandardError => e
          logger.fatal "failed to schedule build #{build.tag}"
          logger.fatal e
        end
      end
    end

    def schedule_builds
      logger.debug 'scheduling the builds...'
      queued_jobs.each_entry do |j|
        begin
          schedule_job(j)
        rescue StandardError => e
          logger.error("failed to schedule job #{j.tag}")
          logger.error(e)
        end
      end
      logger.debug 'processed all builds in the queue'
    end

    def cancel_timedout_pending_jobs
      timeout = Config::UCS.instance.pending_job_timeout
      @agents_manager.timedout_agents(timeout).each(&:cancel_job)
    rescue StandardError => e
      logger.fatal 'failed to cancel timed out pending jobs'
      logger.fatal e
    end

    def schedule_job(job)
      build = job.build
      logger.debug \
        "looking for a capable agent to run the job #{build.tag}-#{job.tag}"
      logger.debug "#{job.tag} requires capabilities: #{job.required_agent_capabilities}"
      agent = @agents_manager.find_agent(job.required_agent_capabilities)
      if agent.nil?
        logger.info "no agents available to run the job #{build.tag}-#{job.tag}"
      else
        job.state = Build::State::PENDING
        @state_manager.put_state(StateManager::Types::BUILD, build.memento)
        agent.run_job(build, job)
        @state_manager.put_state(StateManager::Types::BUILD, build.memento)
      end
    end

    def finished_builds
      @builds.find_all { |b| b.state >= Build::State::ABORTED }
    end

    def queued_builds
      @builds.find_all { |b| b.state == Build::State::QUEUED }
    end

    # Returns an [Enumerator] to enumerator queued jobs
    # @return [Enumerator]
    def queued_jobs
      queued_builds.flat_map(&:stages)
                   .flat_map(&:jobs)
                   .select { |j| j.state == Build::State::QUEUED }
    end
  end
end
