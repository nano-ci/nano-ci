# frozen_string_literal: true

require_relative 'trigger_pulse_event_args'
require_relative '../system/event'

module Nanoci
  module Core
    # TriggerEngine runs triggers and notify [Nanoci::Core::PipelineEngine] througn callback about trigger event
    class TriggerEngine
      # Initializes new instance of [Nanoci::Core::TriggerEngine]
      # @param trigger_repository [Nanoci::TriggerRepository]
      def initialize(trigger_repository)
        @trigger_pulse_event = Nanoci::System::Event.new
        @trigger_repository = trigger_repository
      end

      def trigger_pulse
        @trigger_pulse_event
      end

      protected

      def read_and_lock_next_due_trigger
        @trigger_repository.read_and_lock_next_due_trigger(Time.now.utc)
      end

      def store_and_release_trigger(trigger)
        @trigger_repository.update_and_release_trigger(trigger)
      end

      def due_triggers?
        @trigger_repository.due_triggers? Time.now.utc
      end

      def run_cycle(cancellation_token)
        while @trigger_pulse_event.subscribers? && due_triggers? && !cancellation_token.cancellation_requested?
          trigger = read_and_lock_next_due_trigger
          next if trigger.nil?

          process_trigger trigger
        end
      end

      def process_trigger(trigger)
        outputs = trigger.pulse
        event_args = TriggerPulseEventArgs.new(trigger.project_tag, trigger.full_tag, outputs)
        @trigger_pulse_event.invoke(self, event_args)
      ensure
        store_and_release_trigger trigger
      end
    end
  end
end
