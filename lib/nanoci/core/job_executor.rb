# frozen_string_literal: true

require 'nanoci/not_implemented_error'

module Nanoci
  module Core
    class JobExecutor
      def schedule_job_execution(stage, job, inputs, prev_inputs)
        raise NotImplementedError, 'JobExecutor', 'schedule_job_execution'
      end
    end
  end
end
