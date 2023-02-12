# frozen_string_literal: true

require 'yaml'

require_relative '../../messaging/message'

module Nanoci
  module Core
    module Messages
      # [StageCompleteMessage] signals that stage is complete and contains stage run details
      class StageCompleteMessage < Nanoci::Messaging::Message
        attr_reader :project_tag, :stage_tag, :outputs, :downstream_trigger_rule

        # Initializes new instance of [StageCompleteMessage]
        # @param project_tag [Symbol]
        # @param stage_tag [Symbol]
        # @param outputs [Hash]
        # @param downstream_trigger_rule
        def initialize(project_tag, stage_tag, outputs, downstream_trigger_rule)
          super()

          @project_tag = project_tag
          @stage_tag = stage_tag
          @outputs = outputs.clone.freeze
          @downstream_trigger_rule = downstream_trigger_rule

          self.payload_raw = serialize
        end

        def payload=(value)
          super

          hash = YAML.safe_load(payload_str)
          @project_tag = hash.get(:project_tag)
          @stage_tag = hash.get(:stage_tag)
          @outputs = hash.get(:outputs)
          @downstream_trigger_rule = hash.get(:downstream_trigger_rule)
        end

        private

        def serialize
          hash = {
            project_tag: @project_tag,
            stage_tag: @stage_tag,
            outputs: @outputs,
            downstream_trigger_rule: @downstream_trigger_rule
          }

          YAML.dump(hash)
        end
      end
    end
  end
end
