# frozen_string_literal: true

require 'nanoci/core/job_complete_observer'

module Nanoci
  module Components
    # PipelineJobCompleteObserver publishes result to pipeline engine directly in the same thread
    class PipelineJobCompleteObserver < Nanoci::Core::JobCompleteObserver
      def initialize(pipeline_engine)
        super
        @pipeline_engine = pipeline_engine
      end

      def publish(stage, job, outputs)
        @pipeline_engine.job_complete(stage, job, outputs)
      end
    end
  end
end
