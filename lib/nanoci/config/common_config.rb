# frozen_string_literal: true

module Nanoci
  module Config
    class CommonConfig
      # Initializes new instance of [CommonConfig]
      # @param src [Hash]
      def initialize(src)
        @src = src
      end

      def plugins_path
        @src['plugins-path']
      end
    end
  end
end
