# frozen_string_literal: true

require 'yaml'

require_relative '../../messaging/message'

module Nanoci
  module Core
    module Messages
      # [RunStageMessage] is a signal to run a stage with new inputs
      class RunStageMessage < Messaging::Message
        attr_reader :project_tag, :stage_tag, :next_inputs, :trigger_rule

        def initialize(project_tag, stage_tag, next_inputs, trigger_rule)
          super()
          @project_tag = project_tag
          @stage_tag = stage_tag
          @next_inputs = next_inputs
          @trigger_rule = trigger_rule
        end

        def payload=(value)
          super

          hash = YAML.safe_load(payload_str)
          @project_tag = hash.fetch(:project_tag)
          @stage_tag = hash.fetch(:stage_tag)
          @next_inputs = hash.fetch(:next_inputs)
          @trigger_rule = hash.fetch(:trigger_rule)
        end

        private

        def serialize
          hash = {
            project_tag: @project_tag,
            stage_tag: @stage_tag,
            next_inputs: @next_inputs,
            trigger_rule: @trigger_rule
          }
          YAML.dump(hash)
        end
      end
    end
  end
end
