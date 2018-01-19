require 'eventmachine'

require 'nanoci/build'
require 'nanoci/trigger'

class Nanoci
  class Triggers
    class PollTrigger < Trigger
      attr_accessor :interval
      attr_accessor :schedule

      def initialize(repo, project, hash = {})
        super(repo, project, hash)
        @interval = hash['interval']
        @schedule = hash['schedule']
      end

      def run(build_scheduler)
        super(build_scheduler)

        EventMachine.add_periodic_timer(interval) do
          trigger_build
        end
      end
    end

    Trigger.types['poll'] = PollTrigger
  end
end
