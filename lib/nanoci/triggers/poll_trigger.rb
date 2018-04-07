# frozen_string_literal: true

require 'eventmachine'
require 'logging'

require 'nanoci/build'
require 'nanoci/trigger'

class Nanoci
  # Built-in nano-ci triggers
  class Triggers
    # Poll trigger class
    # Poll trigger is the trigger that checks a repo on a scheduled basis
    class PollTrigger < Trigger
      attr_accessor :interval
      attr_accessor :schedule

      def initialize(repo, hash = {})
        super(repo, hash)

        @log = Logging.logger[self]

        @interval = hash[:interval]
        @schedule = hash[:schedule]
      end

      def run(build_scheduler, project, env)
        super(build_scheduler, project, env)

        EventMachine.add_periodic_timer(interval) do
          trigger_build
        end
      end
    end

    Trigger.types['poll'] = PollTrigger
  end
end
