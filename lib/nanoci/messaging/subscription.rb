# frozen_string_literal: true

require 'concurrent'

require 'nanoci/messaging/message_lease'
require 'nanoci/messaging/message_receipt'

module Nanoci
  module Messaging
    # Subscription is an entity that listens for messages in topic
    class Subscription
      ACK_TIMEOUT = 300

      # Subscription name
      # @return [Symbol]
      attr_reader :name

      # Initializes new instance of [Nanoci::Messaging::Subscription]
      # @param name [String,Symbol]
      def initialize(name)
        @name = name.to_sym
        # @type [Concurrent::Array]
        @message_queue = Concurrent::Array.new
      end

      # Pushes a new message to the subscription
      # @Param msg [Nanoci::Messaging::Message]
      def push(msg)
        @message_queue.push(MessageLease.new(msg))
      end

      # Pulls a next available message from the subscription
      # @return [Nanoci::Messaging::MessageReceipt, nil]
      def pull
        message_lease = @message_queue.reject(&:leased?).first

        return nil if message_lease.nil?

        message_lease.lease(get_next_timeout(message_lease.timeout))
        MessageReceipt.new(message_lease.message, self)
      end

      # Acknowledges and removes the message from subscription
      # @param msg [Nanoci::Messaging::Message]
      def ack(msg_id)
        @message_queue.delete_if { |m| m.message.id == msg_id }
      end

      # Rejects message
      def nack(msg_id)
        # not implemented
      end

      def get_next_timeout(_prev_timeout)
        ACK_TIMEOUT
      end
    end
  end
end
