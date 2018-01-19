require 'logging'
require 'eventmachine'

require 'nanoci/build'

class Nanoci
  class BuildScheduler
    attr_accessor :builds

    def initialize(agents_manager)
      @log = Logging.logger[self]
      @agents_manager = agents_manager
      @builds = []
    end

    def trigger_build(project, trigger)
      @log.info "a new build of project #{project.tag} triggered by #{trigger}"
      build = Nanoci::Build.run(project, trigger, {})
      run_build(build)
    end

    def run_build(build)
      @builds.push(build)
    end

    def run(interval)
      EventMachine.add_periodic_timer(interval) do
        schedule_builds()
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
        @log.debug "looking for a capable agent to run the job #{build.tag}-#{j.definition.tag}"
        agent = @agents_manager.find_agent(j.required_agent_capabilities)
        if agent.nil?
          @log.info "no agents available to run the job #{build.tag}-#{j.definition.tag}"
          next
        end
        agent.run_job(j)
      end
    end

    def queued_builds
      @builds.find_all { |b| b.state == Build::State::QUEUED }
    end

    def queued_jobs(build)
      build.current_stage.jobs.find_all { |j| j.state == Build::State::QUEUED }
    end
  end
end
