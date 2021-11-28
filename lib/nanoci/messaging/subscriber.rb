# frozen_string_literal: true

require 'nanoci/mixins/logger'

module Nanoci
  module Messaging
    # Subscriber pulls messages from a given subscription and execute message handler.
    class Subscriber
      include Nanoci::Mixins::Logger

      # Initializes new instance of [Nanoci::Messaging::Subscriber].
      # @param subscription [Nanoci::Messaging::Subscription]
      def initialize(subscription)
        @subscription = subscription
      end

      # Pulls messages from the subcription and runs message handler on them.
      # @return [Boolean] true if at least one message was pulled. false otherwise.
      def pipe_messages
        receipt = @subscription.pull
        return false if receipt.nil?

        begin
          should_ack = handle_message(receipt.message)
          should_ack ? receipt.ack : receipt.nack
        rescue StandardError => e
          log.error "failed to handle message #{receipt.message.id} from subscription #{@subscription.name}"
          log.error e
          receipt.nack
        end
      end

      # Message handler. Should be implemented in children classes.
      # @param _msg [Nanoci::Messaging::Message] Message to handle.
      # @return [Boolean] true if message was handled and should be ACKed. false if message sholdbe NACKed and put back to queue.
      def handle_message(_msg)
        true
      end
    end
  end
end
