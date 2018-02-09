require 'logging'
require 'eventmachine'

require 'nanoci/build'

class Nanoci
  class BuildScheduler
    attr_accessor :builds

    def initialize(agents_manager, env)
      @log = Logging.logger[self]
      @agents_manager = agents_manager
      @builds = []
      @env = env
    end

    def trigger_build(project, trigger)
      if builds.any? { |x| x.project.tag == project.tag}
        @log.warn "cannot start another build for the project #{project.tag}"
        return
      end

      begin
        build = Nanoci::Build.run(project, trigger, {}, @env)
      rescue StandardError => e
        @log.error "failed to start build for project #{project.tag}"
        @log.error e
        return
      end

      @log.info "a new build #{build.tag} triggered by #{trigger}"

      if build.current_stage.nil?
        @log.warn "build #{build.tag} has no runnable jobs"
        return
      end

      run_build(build)
    end

    def run_build(build)
      builds.push(build)
    end

    def run(interval)
      EventMachine.add_periodic_timer(interval) do
        schedule_builds
        finalize_builds
      end
    end

    def finalize_builds
      finished_builds.each(&:complete)
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
        @log.debug "looking for a capable agent to run the job #{build.tag}-#{j.tag}"
        agent = @agents_manager.find_agent(j.required_agent_capabilities)
        if agent.nil?
          @log.info "no agents available to run the job #{build.tag}-#{j.tag}"
          next
        end
        agent.run_job(build, j)
      end
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
