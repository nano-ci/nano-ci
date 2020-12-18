# frozen_string_literal: true

module Nanoci
  module DSL
    # TriggerDSL class contains methods to support nano-ci trigger DSL.
    class TriggerDSL
      def initialize(tag)
        @tag = tag
      end

      def repo(repo_tag)
        @repo = repo_tag
      end

      def schedule(schedule)
        @schedule = schedule
      end

      def build
        {
          tag: @tag,
          repo: @repo,
          schedule: @schedule
        }
      end
    end
  end
end
