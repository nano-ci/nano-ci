# frozen_string_literal: true

module Nanoci
  module System
    # Observable event. Allows for objects notify other objects when something happens.
    class Event
      def initialize
        @counter = 0
        @subscribers = {}
      end

      def attach(&handler)
        raise ArgumentError, 'handler is not a Proc' unless handler.is_a? Proc
        raise ArgumentError, 'handler should have 2 args' unless handler.arity == 2

        token = @counter
        @counter += 1
        @subscribers[token] = handler

        token
      end

      def detach(token)
        raise ArgumentError, 'unknown handler token' unless @subscribers.key? token

        @subscribers.delete token
      end

      def invoke(sender, event_args)
        @subscribers.each_value do |handler|
          handler.call(sender, event_args)
        end
      end
    end
  end
end
