# frozen_string_literal: true

require 'nanoci/core/trigger'

module Nanoci
  module DSL
    # TriggerDSL class contains methods to support nano-ci trigger DSL.
    class TriggerDSL
      def initialize(tag, project_tag)
        @tag = tag
        @project_tag = project_tag
      end

      def build
        Nanoci::Core::Trigger.new(tag: @tag, project_tag: @project_tag)
      end
    end
  end
end
