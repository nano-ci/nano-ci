# frozen_string_literal: true

require 'logging'
require 'eventmachine'

require 'nanoci/build'

class Nanoci
  ##
  # Build scheduler maintains queue of jobs
  # and schedules job execution on build agents
  class BuildScheduler
    attr_accessor :builds

    def initialize(agents_manager, state_manager, env)
      @log = Logging.logger[self]
      @agents_manager = agents_manager
      @state_manager = state_manager
      @builds = []
      @env = env
    end

    def start_new_build(project, trigger)
      build = Nanoci::Build.run(project, trigger, {}, @env)
      @state_manager.put_state(StateManager::Types::PROJECT, project.state)
      @log.info "a new build #{build.tag} triggered by #{trigger}"
      build
    rescue StandardError => e
      @log.error "failed to run a new build for project #{project.tag}"
      @log.error e
    end

    def trigger_build(project, trigger)
      if builds.any? { |x| x.project.tag == project_tag }
        @log.warn "cannot start another build for the project #{project.tag}"
        return
      end

      build = start_new_build(project, trigger)

      if build.current_stage.nil?
        @log.warn "build #{build.tag} has no runnable jobs"
      else
        run_build(build)
      end
    end

    def run_build(build)
      builds.push(build)
      @state_manager.put_state(StateManager::Types::BUILD, build.memento)
    end

    def run(interval)
      EventMachine.add_periodic_timer(interval) do
        schedule_builds
        finalize_builds
      end
    end

    def finalize_builds
      finished_builds.each do |build|
        build.complete
        @state_manager.put_state(StateManager::Types::BUILD, build.memento)
        @builds.delete build
        @log.info "finished build #{build.tag}"
      end
    end

    def schedule_builds
      @log.debug 'scheduling the builds...'
      queued_builds.each do |b|
        schedule_build(b)
      end
      @log.debug 'processed all builds in the queue'
    end

    def schedule_build(build)
      queued_jobs(build).each_entry do |j|
        schedule_job(build, j)
      end
    end

    def schedule_job(build, job)
      @log.debug \
        "looking for a capable agent to run the job #{build.tag}-#{job.tag}"
      agent = @agents_manager.find_agent(j.required_agent_capabilities)
      if agent.nil?
        @log.info "no agents available to run the job #{build.tag}-#{job.tag}"
        next
      end
      agent.run_job(build, job)
      @state_manager.put_state(StateManager::Types::BUILD, build.memento)
    end

    def finished_builds
      @builds.find_all { |b| b.state >= Build::State::ABORTED }
    end

    def queued_builds
      @builds.find_all { |b| b.state == Build::State::QUEUED }
    end

    def queued_jobs(build)
      build.current_stage.jobs.find_all { |j| j.state == Build::State::QUEUED }
    end
  end
end
