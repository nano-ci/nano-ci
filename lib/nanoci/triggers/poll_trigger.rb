# frozen_string_literal: true

require 'eventmachine'
require 'logging'

require 'nanoci/build'
require 'nanoci/definition/poll_trigger_definition'
require 'nanoci/trigger'

class Nanoci
  # Built-in nano-ci triggers
  class Triggers
    # Poll trigger class
    # Poll trigger is the trigger that checks a repo on a scheduled basis
    class PollTrigger < Trigger
      provides 'poll'

      attr_accessor :interval

      def initialize(repo, definition)
        definition = Nanoci::Definition::PollTriggerDefinition.new(definition.params)
        super(repo, definition)

        @log = Logging.logger[self]

        @interval = definition.interval
      end

      def run(build_scheduler, project, env)
        super(build_scheduler, project, env)

        EventMachine.add_periodic_timer(interval) do
          trigger_build
        end
      end
    end
  end
end
