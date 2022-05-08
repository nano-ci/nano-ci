# frozen_string_literal: true

require 'nanoci/core/stage_complete_observer'

module Nanoci
  module Components
    # Stage complete observer that notifies pipeline about that.
    class PipelineStageCompleteObserver < Core::StageCompleteObserver
      def initialize(pipeline_engine)
        super
        @pipeline_engine = pipeline_engine
      end

      def pulse(tag, outputs)
        @pipeline_engine.stage_complete(tag, outputs)
      end
    end
  end
end
