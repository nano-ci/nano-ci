# frozen_string_literal: true

require_relative 'cancellation_token'

module Nanoci
  module System
    # Signals to [CancellationToken] that cancellation is requested
    class CancellationTokenSource
      def cancellation_requested? = @cancellation_requested

      def initialize
        @cancellation_requested = false
      end

      def token
        CancellationToken.new(self)
      end

      def request_cancellation
        @cancellation_requested = true
      end
    end
  end
end
