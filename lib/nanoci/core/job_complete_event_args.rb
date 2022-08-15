# frozen_string_literal: true

module Nanoci
  module Core
    # Event args for Job Complete event
    class JobCompleteEventArgs
      attr_reader :project_tag, :stage_tag, :job_tag, :outputs

      def initialize(project, stage, job, outputs)
        @project_tag = project
        @stage_tag = stage
        @job_tag = job
        @outputs = outputs
      end
    end
  end
end
