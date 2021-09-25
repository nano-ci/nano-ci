# frozen_string_literal: true

module Nanoci
  module Messaging
    # Message is a basic communication element. Message contains metadata and payload.
    class Message
      # Unique message Id. Id is set when message is published.
      # Id format depends on messaging component implementation.
      # @return [String]
      attr_reader :id

      # Time in UTC timezone when the message was published.
      # @return [Time]
      attr_reader :publish_time_utc

      # Collection of custom attributes.
      # @return [Hash]
      attr_reader :attributes

      # Raw payload of the message.
      # @return [Array] Byte array with message payload
      attr_reader :payload

      # Set message payload
      # @param value [String, Array<Integer>, nil]
      def payload=(value)
        raise ArgumentError, "Expected value to be nil, String, or Array of bytes, got #{value.class}" \
          unless value.nil? || value.is_a?(String) || (value.is_a?(Array) && value.all? { |e| !byte? e })

        @payload = value.is_a?(String) ? value.encode('utf-8').bytes : value
      end

      def payload_str
        @payload.pack('c*').force_encoding('utf-8')
      end

      def initialize
        @attributes = {}
      end

      private

      def byte?(value)
        !value.nil? && value.is_a?(Integer) && (value.negative? || value > 255)
      end
    end
  end
end
