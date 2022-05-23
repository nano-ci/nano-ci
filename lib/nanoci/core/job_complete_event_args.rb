# frozen_string_liteal: true

module Nanoci
  module Core
    # Event args for Job Complete event
    class JobCompleteEventArgs
      attr_reader :stage, :job, :outputs

      def initialize(stage, job, outputs)
        @stage = stage
        @job = job
        @outputs = outputs
      end
    end
  end
end
