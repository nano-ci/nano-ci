# frozen_string_literal: true

module Nanoci
  module Messaging
    # Tracks message lease and lease expiration
    class MessageLease
      attr_reader :message_id
      attr_accessor :leased?, :deadline

      def initialize(message_id, deadline)
        @message_id = message_id
        @deadline = deadline
      end

      def expired?
        Time.now.utc > deadline
      end
    end
  end
end
