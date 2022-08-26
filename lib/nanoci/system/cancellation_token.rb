# frozen_string_literal: true

module Nanoci
  module System
    # Notifies long-running methods that cancellation is requested
    class CancellationToken
      def initialize(source)
        @source = source
      end

      def cancellation_requested? = @source.cancellation_requested?
    end
  end
end
