# frozen_string_literal: true

require 'singleton'

require_relative 'job_scheduled_event'

module Nanoci
  module Core
    # Queue for domain events
    class DomainEvents
      include Singleton

      def initialize
        @queue = Queue.new
      end

      def empty? = @queue.empty?

      def push(event) = @queue.push(event)

      def shift = empty? ? nil : @queue.shift
    end
  end
end
