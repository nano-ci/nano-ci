# frozen_string_literal: true

module Nanoci
  module Events
    # Data model for the event that signals about stage finish.
    class StageFinishedEvent
      attr_reader :stage, :stage_tag, :outputs

      # Initializes new instance of [Nanoci::Events::StageFinishedEvent]
      # @param stage [Nanoci::Stage]
      # @param outputs [Hash]
      def initialize(stage, outputs)
        @stage = stage
        @stage_tag = stage.tag
        @outputs = outputs
      end
    end
  end
end
