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
        # @type [Concurrent::Hash]
        @lease = Concurrent::Hash.new
      end

      # Pushes a new message to the subscription
      # @Param msg [Nanoci::Messaging::Message]
      def push(msg)
        @message_queue.push(msg)
        @lease[msg.id] = MessageLease.new(mgs.id, get_next_deadline(nil))
      end

      # Pulls a next available message from the subscription
      # @return [Nanoci::Messaging::MessageReceipt, nil]
      def pull
        msg = @message_queue
              .select { |e| @lease.key?(e.id) && (!@lease[e.id].leased? || @lease[e.id].expired?) }
              .first
        msg.nil? ? nil : MessageReceipt.new(msg, self)
      end

      # Acknowledges and removes the message from subscription
      # @param msg [Nanoci::Messaging::Message]
      def ack(msg_id)
        @message_queue.delete_if { |m| m.id == msg_id }
      end

      # Rejects message
      def nack(msg_id)
        # not implemented
      end

      def get_next_deadline(_prev_deadline)
        Time.now.utc + ACK_TIMEOUT
      end
    end
  end
end
