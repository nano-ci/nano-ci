# frozen_string_literal: true

require 'logging'

require 'nanoci'
require 'nanoci/build'
require 'nanoci/definition/poll_trigger_definition'
require 'nanoci/trigger'

module Nanoci
  # Built-in nano-ci triggers
  module Triggers
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

      def run(build_scheduler, project)
        super(build_scheduler, project)

        @timer = Concurrent::TimerTask.new(execution_interval: @interval) do
          trigger_build
        end
        @timer.execute
      end
    end
  end
end
