# frozen_string_literal: true

module Nanoci
  # Module to group config classes
  module Config
    # nano-ci agent service config
    class AgentConfig < CommonConfig
      def tag
        @src['tag']
      end

      def capabilities
        caps = (@src['capabilities'] || []).map do |x|
          case x
          when String then [x, nil]
          when Hash then x.entries[0]
          end
        end
        caps.map { |x| [x[0].to_sym, x[1]] }.to_h
      end

      def repo_cache
        @src['repo-cache']
      end

      def workdir
        @src['workdir']
      end
    end
  end
end
