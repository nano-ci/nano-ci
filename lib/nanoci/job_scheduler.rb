require 'eventmachine'

require 'nanoci/build'

class Nanoci
  class JobScheduler
    attr_accessor :builds

    def initialize(agents_manager)
      @agents_manager = agents_manager
      @builds = []
    end

    def run_build(build)
      @builds.push(build)
      build.run
    end

    def run(interval)
      EventMachine.add_periodic_timer(interval) do
        schedule_builds()
      end
    end

    def schedule_builds
      queued_builds.each do |b|
        schedule_build(b)
      end
    end

    def schedule_build(build)
      queued_jobs(build).each_entry do |j|
        agent = @agents_manager.find_agent(j.required_agent_capabilities)
        next if agent.nil?
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
