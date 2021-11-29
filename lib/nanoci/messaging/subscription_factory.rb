# frozen_string_literal: true

require 'nanoci/messaging/subscription'

module Nanoci
  module Messaging
    class SubscriptionFactory
      def initialize
        # @type [Hash{Symbol => Nanoci::Messaging::Subscription}]
        @subscriptions = Hash.new { |_hash, name| Subscription.new(name) }
      end

      # Creates a new subscription or return if such subscription exists
      # @param name [Symbol] Name of the subscription
      # @return [Nanoci::Messaging::Subscription]
      def create_subscription(name)
        raise ArgumentError, 'name is not a Symbol' unless name.is_a? Symbol

        @subscriptions[name]
      end
    end
  end
end
