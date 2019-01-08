# frozen_string_literal: true

require 'concurrent'
require 'concurrent-edge'

module Nanoci
  # EventQueue provides sync access to queue of events for [AgentEngine] to handle
  class EventQueue
    def initialize
      @queue = Concurrent::Promises::Channel.new
    end

    # Adds a new event to the queue
    # @param event [Nanoci::Event] event to enqueue
    # @return [Concurrent::Future] future to monitor that event is added to the queue
    def enqueue(event)
      @queue.push(event)
    end

    # Fetches an event from the queue
    # @ return [Concurrent::Future] future with event
    def dequeue
      @queue.pop
    end
  end
end
