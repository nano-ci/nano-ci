# frozen_string_literal: true

module Nanoci
  module DSL
    # TriggerDSL class contains methods to support nano-ci trigger DSL.
    class TriggerDSL
      def initialize(tag)
        @tag = tag
      end

      # rubocop:disable  Style/TrivialAccessors

      def type(type)
        @type = type
      end

      def repo(repo_tag)
        @repo = repo_tag
      end

      def interval(interval_sec)
        @interval = interval_sec
      end

      # rubocop:enable  Style/TrivialAccessors

      def build
        {
          tag: @tag,
          type: @type,
          repo: @repo,
          interval: @interval
        }
      end
    end
  end
end
