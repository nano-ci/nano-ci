# frozen_string_literal: true

module Nanoci
  module Messaging
    # Tracks message lease and lease expiration
    class MessageLease
      # Unique message Id
      # @return [String]
      attr_reader :message_id

      # Deadline for message lease. Lease is considered expired if deadline is in past
      # @return [Time]
      attr_reader :deadline

      def initialize(message_id)
        @message_id = message_id
        @is_leased = false
      end

      def expired?
        !deadline.nil? && Time.now.utc > deadline
      end

      def leased?
        @is_leased
      end

      def lease(deadline)
        raise StandardError, 'Message is already leased' if leased?

        @deadline = deadline
        @is_leased = true
      end

      def release
        @deadline = nil
        @is_leased = false
      end
    end
  end
end
