require 'eventmachine'
require 'logging'

require 'nanoci/build'
require 'nanoci/trigger'

class Nanoci
  class Triggers
    class PollTrigger < Trigger
      attr_accessor :interval
      attr_accessor :schedule

      def initialize(repo, project, hash = {})
        super(repo, project, hash)

        @log = Logging.logger[self]

        @interval = hash['interval']
        @schedule = hash['schedule']
      end

      def run(build_scheduler, env)
        super(build_scheduler, env)

        EventMachine.add_periodic_timer(interval) do
          @log.info "checking repo #{@repo.tag} for new changes"
          trigger_build
        end
      end
    end

    Trigger.types['poll'] = PollTrigger
  end
end
