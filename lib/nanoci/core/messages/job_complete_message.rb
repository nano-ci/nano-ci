# frozen_string_literal: true

require 'yaml'

require_relative '../../messaging/message'

module Nanoci
  module Core
    module Messages
      # [StageCompleteMessage] signals that job is complete and contains stage run details
      class JobCompleteMessage < Nanoci::Messaging::Message
        attr_reader :project_tag, :stage_tag, :job_tag, :outputs

        # Initializes new instance of [StageCompleteMessage]
        # @param project_tag [Symbol]
        # @param stage_tag [Symbol]
        # @param job_tag [Symbol]
        # @param outputs [Hash]
        def initialize(project_tag, stage_tag, job_tag, outputs)
          super()

          @project_tag = project_tag
          @stage_tag = stage_tag
          @job_tag = job_tag
          @outputs = outputs.clone.freeze

          self.payload_raw = serialize
        end

        def payload=(value)
          super

          hash = YAML.safe_load(payload_str)
          @project_tag = hash.fetch(:project_tag)
          @stage_tag = hash.fetch(:stage_tag)
          @stage_tag = hash.fetch(:job_tag)
          @outputs = hash.fetch(:outputs)
        end

        private

        def serialize
          hash = {
            project_tag: @project_tag,
            stage_tag: @stage_tag,
            job_tag: @job_tag,
            outputs: @outputs
          }
          YAML.dump(hash)
        end
      end
    end
  end
end
