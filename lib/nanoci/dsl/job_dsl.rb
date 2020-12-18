# frozen_string_literal: true

module Nanoci
  module DSL
    # JobDSL class contains methods to support nano-ci DSL
    class JobDSL
      def initialize(tag, params, block)
        @tag = tag
        @work_dir = params.fetch(:work_dir, '.')
        @block = block
      end

      def build
        {
          tag: @tag,
          work_dir: @work_dir,
          block: @block
        }
      end
    end
  end
end
