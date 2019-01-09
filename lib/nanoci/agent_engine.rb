# frozen_string_literal: true

require 'concurrent'

require 'nanoci/agent_status'
require 'nanoci/config/ucs'
require 'nanoci/event_queue'
require 'nanoci/events/report_status_event'
require 'nanoci/local_agent'
require 'nanoci/mixins/logger'
require 'nanoci/remote/agent_manager_service_client'

module Nanoci
  # nano-ci Agent engine
  class AgentEngine
    include Mixins::Logger

    def initialize
      # @type [Nanoci::Remote:;AgentManagerServiceClient]
      @service_client = Remote::AgentManagerServiceClient.new

      @agent = LocalAgent.new

      # @type [Hash<Class, Method>]
      @handlers = {
        Events::ReportStatusEvent => method(:handle_report_status)
      }

      # @type [EventQueue]
      @queue = EventQueue.new
      interval = Config::UCS.instance.report_status_interval

      # @type [Concurrent::TimerTask]
      @report_status_timer = Concurrent::TimerTask.new(execution_interval: interval, run_now: true) do
        schedule_report_status
      end
    end

    # Runs the [AgentEngine]
    def run
      log.info('AgentEngine is running')
      @report_status_timer.execute
      event_loop
      log.info('AgentEngine is stopped')
    end

    # Enqueues a new task to execute
    # @param event [Nanoci::Event]
    def enqueue_task(event)
      log.debug "enqueueing a new event #{event}"
      @queue.enqueue(event)
    end

    private

    # Runs loop to handle events from queue
    def event_loop
      loop do
        event_promise = @queue.dequeue
        begin
          event = event_promise.value!
          log.debug("took an event #{event} from event queue")
        rescue StandardError
          raise 'failed to dequeue event from event queue'
        end

        dispatch(event)
      end
    end

    # Dispatches event to appropriate handler
    def dispatch(event)
      log.info("dispatching event #{event}")
      event_class = event.class
      raise "unknown event class #{event_class}" unless @handlers.key?(event_class)
      handler = @handlers.fetch(event_class)
      handler.call(event)
      log.info("event #{event} dispatched")
    rescue StandardError => e
      log.error "failed to dispatch #{event}"
      log.error e
    end

    def schedule_report_status
      event = Events::ReportStatusEvent.new
      enqueue_task(event)
    end

    def handle_report_status(_event)
      log.debug('reporting agent status...')
      tag = @agent.tag
      status = AgentStatus.key(@agent.status)
      capabilities = @agent.capabilities.keys
      @service_client.report_agent_status(tag, status, capabilities)
      log.debug('successfully reported agent status')
    end
  end
end
