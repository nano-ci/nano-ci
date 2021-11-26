# frozen_string_literal: true

module Nanoci
  module Messaging
    # Tracks message lease and lease expiration
    class MessageLease
      # Unique message Id
      # @return [Nanoci::Messaging::Message]
      attr_reader :message_id

      # Message lease timeout
      # @return [Number]
      attr_reader :timeout

      # Deadline for message lease. Lease is considered expired if deadline is in past
      # @return [Time]
      attr_reader :deadline

      # Initializes new instance of [Nanoci::Messaging::Message]
      def initialize(message)
        @message = message
        @is_leased = false
      end

      def expired?
        !deadline.nil? && Time.now.utc > deadline
      end

      def leased?
        @is_leased && !expired?
      end

      def lease(timeout)
        raise StandardError, 'Message is already leased' if leased?

        @timeout = timeout
        @deadline = Time.now.utc + timeout
        @is_leased = true
      end

      def release
        @deadline = nil
        @is_leased = false
      end
    end
  end
end
