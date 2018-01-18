require 'eventmachine'

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

      def run
        super

        EventMachine.add_periodic_timer(interval) do
          @project.trigger_build(self) if @repo.detect_changes
        end
      end
    end

    Trigger.types['poll'] = PollTrigger
  end
end
