# frozen_string_literal: true

module Nanoci
  module Core
    # Event args for Trigger#pulse event
    class TriggerPulseEventArgs
      # Gets trigger that raised the pulse event
      # @return [Nanoci::Core::Trigger]
      attr_reader :trigger
      # Gets a Hash with the trigger outputs
      # @return [Hash]
      attr_reader :outputs

      def initialize(trigger, outputs)
        @trigger = trigger
        @outputs = outputs
      end
    end
  end
end
