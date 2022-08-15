# frozen_string_literal: true

require 'logging'

module Nanoci
  class Mixins
    ##
    # Mixin class that enables logging for a class
    module Logger
      def log
        Logging.logger[self]
      end

      # Creates a structured log event for errors
      # @param message [String]
      # reason [Error]
      # @return [Hash]
      def error_log_event(message, reason: nil)
        {
          message: message,
          reason: reason.full_message
        }
      end
    end
  end
end
