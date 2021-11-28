# frozen_string_literal: true

module Nanoci
  module Events
    class JobFinishedEvent
      attr_accessor :project, :project_tag, :stage, :stage_tag, :job, :job_tag, :outputs, :success

      def initialize(project, stage, job, outputs, success)
        @project = project
        @project_tag = project.tag
        @stage = stage
        @stage_tag = stage.tag
        @job = job
        @job_tag = job.tag
        @outputs = outputs
        @success = success
      end
    end
  end
end
