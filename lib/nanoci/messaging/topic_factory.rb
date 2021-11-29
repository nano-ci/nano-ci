# frozen_string_literal: true

require 'nanoci/messaging/topic'

module Nanoci
  module Messaging
    class TopicFactory
      def initialize
        # @type [Hash{Symbol => Nanoci::Messaging::Topic}]
        @topics = Hash.new { |_hash, name| Topic.new(name) }
      end

      # Creates a new topic or return if such topic exists
      # @param name [Symbol] Name of the topic
      # @return [Nanoci::Messaging::Topic]
      def create_topic(name)
        raise ArgumentError, 'name is not a Symbol' unless name.is_a? Symbol

        @topics[name]
      end
    end
  end
end
