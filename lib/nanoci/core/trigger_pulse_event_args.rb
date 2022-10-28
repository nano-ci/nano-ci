# frozen_string_literal: true

module Nanoci
  module Core
    # Event args for Trigger#pulse event
    class TriggerPulseEventArgs
      # Gets tag of the project that contains the trigger
      # @return [Symbol]
      attr_reader :project_tag

      # Gets trigger that raised the pulse event
      # @return [Symbol]
      attr_reader :trigger_tag
      # Gets a Hash with the trigger outputs
      # @return [Hash]
      attr_reader :outputs

      def initialize(project_tag, trigger_tag, outputs)
        @project_tag = project_tag
        @trigger_tag = trigger_tag
        @outputs = outputs
      end
    end
  end
end
