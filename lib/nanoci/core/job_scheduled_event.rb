# frozen_string_literal: true

module Nanoci
  module Core
    # Domain event raised when job is scheduled
    class JobScheduledEvent
      attr_accessor :project_tag, :stage_tag, :job_tag

      def initialize(project_tag, stage_tag, job_tag)
        @project_tag = project_tag
        @stage_tag = stage_tag
        @job_tag = job_tag
      end
    end
  end
end
