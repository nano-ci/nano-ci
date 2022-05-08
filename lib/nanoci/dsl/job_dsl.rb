# frozen_string_literal: true

require 'nanoci/core/job'

module Nanoci
  module DSL
    # JobDSL class contains methods to support nano-ci DSL
    class JobDSL
      def initialize(component_factory, tag, work_dir: '.', &block)
        @component_factory = component_factory
        @tag = tag
        @work_dir = work_dir
        @block = block
      end

      def build
        Core::Job.new(
          tag: @tag,
          body: @block,
          work_dir: @work_dir
        )
      end
    end
  end
end
