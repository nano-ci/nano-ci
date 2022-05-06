# frozen_string_literal: true

require 'nanoci/core/job_result_publisher'

module Nanoci
  module Components
    # DirectJobResultPublisher publishes result to pipeline engine directly in the same thread
    class DirectJobResultPublisher < Nanoci::Core::JobResultPublisher
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
