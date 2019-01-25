# frozen_string_literal: true

require 'logging'

require 'nanoci'
require 'nanoci/build'
require 'nanoci/config/ucs'
require 'nanoci/state_manager'

module Nanoci
  ##
  # Build scheduler maintains queue of jobs
  # and schedules job execution on build agents
  class BuildScheduler
    attr_accessor :builds

    def initialize(agents_manager, state_manager)
      @log = Logging.logger[self]
      @agents_manager = agents_manager
      @state_manager = state_manager
      @builds = []
    end

    def start_new_build(project, trigger)
      build = Nanoci::Build.run(project, trigger, Config::UCS.instance.env)
      @state_manager.put_state(StateManager::Types::PROJECT, project.state)
      @log.info "a new build #{build.tag} triggered by #{trigger}"
      build
    rescue StandardError => e
      @log.error "failed to run a new build for project #{project.tag}"
      @log.error e
      nil
    end

    def trigger_build(project, trigger)
      if duplicate_build?(project.tag)
        @log.warn "cannot start another build for the project #{project.tag}"
      else
        trigger_new_build(project, trigger)
      end
    end

    def trigger_new_build(project, trigger)
      build = start_new_build(project, trigger)

      # build was not started due to error, exit
      return if build.nil?

      if build.current_stage.nil?
        @log.warn "build #{build.tag} has no runnable jobs"
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
      @log.info "running BuildScheduler"

      @timer = Concurrent::TimerTask.new(execution_interval: interval) do
        begin
          schedule_builds
        rescue StandardError => e
          @log.fatal 'failed to schedule builds'
          @log.fatal e
        end
        begin
          finalize_builds
        rescue StandardError => e
          @log.fatal 'failed to finalize builds'
          @log.fatal e
        end
      end
      @timer.execute
    end

    def finalize_builds
      finished_builds.each do |build|
        build.complete
        @state_manager.put_state(StateManager::Types::BUILD, build.memento)
        project = build.project
        project.build_number = build.number
        @state_manager.put_state(StateManager::Types::PROJECT, project.state)
        @builds.delete build
        @log.info "finished build #{build.tag} in state #{Build::State.to_sym(build.state)}"
      end
    end

    def schedule_builds
      @log.debug 'scheduling the builds...'
      queued_jobs.each_entry do |j|
        begin
          schedule_job(j)
        rescue StandardError => e
          @log.error("failed to schedule job #{j.tag}")
          @log.error(e)
        end
      end
      @log.debug 'processed all builds in the queue'
    end

    def schedule_job(job)
      build = job.build
      @log.debug \
        "looking for a capable agent to run the job #{build.tag}-#{job.tag}"
      @log.debug "#{job.tag} requires capabilities: #{job.required_agent_capabilities}"
      agent = @agents_manager.find_agent(job.required_agent_capabilities)
      if agent.nil?
        @log.info "no agents available to run the job #{build.tag}-#{job.tag}"
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
      queued_builds.flat_map(&:stages).flat_map(&:jobs).select { |j| j.state == Build::State::QUEUED }
    end
  end
end
