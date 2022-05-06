# frozen_string_literal: true

require 'nanoci/not_implemented_error'

module Nanoci
  module Core
    # Publishes job execution result
    class JobResultPublisher
      def publish(stage, job, outputs)
        raise NotImplementedError
      end
    end
  end
end
