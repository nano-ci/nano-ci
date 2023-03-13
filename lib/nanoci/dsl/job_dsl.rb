# frozen_string_literal: true

require 'nanoci/core/job'

module Nanoci
  module DSL
    # JobDSL class contains methods to support nano-ci DSL
    class JobDSL
      def initialize(component_factory, tag, stage_tag, project_tag, work_dir: '.', env: nil, &block)
        @component_factory = component_factory
        @tag = tag
        @stage_tag = stage_tag
        @project_tag = project_tag
        @work_dir = work_dir
        @env = env
        @block = block
      end

      def build
        Core::Job.new(
          tag: @tag,
          stage_tag: @stage_tag,
          project_tag: @project_tag,
          body: @block,
          work_dir: @work_dir,
          env: @env
        )
      end
    end
  end
end
