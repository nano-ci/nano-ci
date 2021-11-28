# frozen_string_literal: true

module Nanoci
  module Events
    # Data model for event to execute a job.
    class ExecuteJobEvent
      attr_accessor :project, :project_tag, :stage, :stage_tag, :job, :job_tag, :inputs, :prev_inputs

      def initialize(project, stage, job, inputs, prev_inputs)
        @project = project
        @project_tag = project.tag
        @stage = stage
        @stage_tag = stage.tag
        @job = job
        @job_tag = job.tag
        @inputs = inputs
        @prev_inputs = prev_inputs
      end
    end
  end
end
