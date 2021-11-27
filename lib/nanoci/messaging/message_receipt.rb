# frozen_string_literal: true

module Nanoci
  module Messaging
    # MessageReceipt is a message envelope that gives option to ack or nack the message.
    class MessageReceipt
      # Message
      # @return [Nanoci::Messaging::Message]
      attr_reader :message

      # Initializes new instance of [Nanoci::Messaging::MessageReceipt]
      # @param msg [Nanoci::Messaging::Message]
      # @param subscription [Nanoci::Messaging::Subscription]
      def initialize(msg, subscription)
        @message = msg
        @subscription = subscription
      end

      def ack
        @subscription.ack(message.id)
      end

      def nack
        @subscription.nack(message.id)
      end
    end
  end
end
