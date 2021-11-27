# frozen_string_literal: true

require 'concurrent'

module Nanoci
  module Messaging
    # Topic is a component that receives published messages and forwards the messages
    # to 0..n attached subscriptions.
    class Topic
      # Name of the topic
      # @return [Symbol]
      attr_reader :name

      # A read-only array of attached subscriptions
      # @return [Array<Nanoci::Messaging::Subscription>]
      def subscriptions
        @subscriptions.dup.freeze
      end

      # Initializes new instance of [Nanoci::Messaging::Topic]
      # @param name [String,Symbol]
      def initialize(name)
        @counter = 0
        @name = name.to_sym
        # @type [Array<Nanoci::Messaging::Nanoci>]
        @subscriptions = []
      end

      # Publishes a message to the topic
      # @param msg [Nanoci::Messaging::Message]
      # @return [Concurrent::Promises::Future] A future with a published message.
      def publish(msg)
        msg.id = next_msg_id
        msg.publish_time_utc = Time.now.utc

        @subscriptions.each do |s|
          s.push(msg)
        end
        Concurrent::Promises.fulfilled_future(msg)
      end

      # Attaches a subscription to the topic
      # @param subscription [Nanoci::Messaging::Subscription]
      def attach(subscription)
        @subscriptions.push(subscription)
      end

      def detach(subscription)
        @subscriptions.delete_if { |s| s == subscription }
      end

      private

      def next_msg_id
        next_id = @counter
        @counter += 1
        next_id
      end
    end
  end
end
