require 'eventmachine'

require 'nanoci/build'

class Nanoci
  class JobScheduler
    def initialize(agents_manager)
      @agents_manager = agents_manager
      @builds = []
    end

    def run_build(build)
      @builds.push[build]
      build.run
    end

    def run(interval)
      EventMachine.add_periodic_timer(interval) do
        @builds.find_all { |b| b.state == Build.State::Queued }.each do |b|
          schedule_build(b)
        end
      end
    end

    def schedule_build(build)
      build.current_stage.jobs
           .find_all { |j| j.state == Build.State::Queued }
           .each_entry do |j|
        agent = @agents_manager.find_agent(j.required_agent_capabilities)
        next if agent.nil?
        agent.run_job(j)
      end
    end
  end
end
