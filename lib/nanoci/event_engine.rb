# frozen_string_literal: true

require 'concurrent'
require 'logging'

require 'nanoci/event'
require 'nanoci/event_queue'

module Nanoci
  # An engine that implements event loop
  class EventEngine
    include Logging.globally

    def initialize(handlers = {})
      @handlers = handlers
      @queue = EventQueue.new
    end

    def register(handlers)
      @handlers.merge!(handlers)
    end

    # Posts a new event to execute
    # @param event_type [Symbol] event type
    # @data [Object] event data
    def post(event_type, data = nil)
      enqueue_task(Event.new(event_type, data))
    end

    # Enqueues a new task to execute
    # @param event [Nanoci::Event]
    def enqueue_task(event)
      logger.debug "enqueueing a new event #{event}"
      @queue.enqueue(event)
    end

    # Runs the event engine
    def run
      @run_future = Concurrent::Promises.future do
        event_loop
      end
    end

    def stop
      enqueue_task(Event.new(STOP))
      @run_future
    end

    private

    STOP = :stop

    # Gets a handlers hash
    # @return [Hash]
    attr_reader :handlers

    # Gets an events queue
    # @return [EventQueue]
    attr_reader :queue

    # Runs loop to handle events from queue
    def event_loop
      loop do
        begin
          event = @queue.dequeue.value!
          logger.debug("took an event #{event} from event queue")
        rescue StandardError
          raise 'failed to dequeue event from event queue'
        end

        break if event.type == STOP

        dispatch(event)
      end
    end

    # Dispatches event to appropriate handler
    def dispatch(event)
      logger.info("dispatching event #{event}")
      raise "unknown event class #{event.type}" unless handlers.key?(event.type)

      handler = handlers.fetch(event.type)
      call_handler(handler, event)
      logger.info("event #{event} dispatched")
    end

    # Calls event handler
    def call_handler(handler, event)
      case handler.arity
      when 0
        handler.call
      when 1
        handler.call(event.data)
      end
    rescue StandardError => e
      logger.error "failed to dispatch #{event}"
      logger.error e
    end
  end
end
