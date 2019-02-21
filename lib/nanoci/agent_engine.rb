# frozen_string_literal: true

require 'concurrent'

require 'nanoci/agent_status'
require 'nanoci/config/ucs'
require 'nanoci/event_queue'
require 'nanoci/events/get_next_job_event'
require 'nanoci/events/report_job_state_event'
require 'nanoci/events/report_status_event'
require 'nanoci/local_agent'
require 'nanoci/remote/agent_manager_service_client'

module Nanoci
  # nano-ci Agent engine
  class AgentEngine
    include Logging.globally

    # Initializes new instance of [AgentEngine]
    def initialize
      # @type [Nanoci::Remote:;AgentManagerServiceClient]
      @service_client = Remote::AgentManagerServiceClient.new

      # @type [Nanoci::LocalAgent]
      @agent = LocalAgent.new

      # @type [EventQueue]
      @queue = EventQueue.new
      interval = Config::UCS.instance.report_status_interval

      # @type [Concurrent::TimerTask]
      @report_status_timer = Concurrent::TimerTask.new(execution_interval: interval, run_now: true) do
        schedule_report_status
        unless @agent.current_job.nil?
          schedule_job_state_report(@agent.job_execution_result)
        end
      end
    end

    # Runs the [AgentEngine]
    def run
      logger.info('AgentEngine is running')
      @report_status_timer.execute
      event_loop
      logger.info('AgentEngine is stopped')
    end

    # Enqueues a new task to execute
    # @param event [Nanoci::Event]
    def enqueue_task(event)
      logger.debug "enqueueing a new event #{event}"
      @queue.enqueue(event)
    end

    private

    # Returns a map of event handlers
    # @return [Hash<Class, Method>]
    def handlers
      @handlers ||= {
        Events::ReportStatusEvent => method(:handle_report_status),
        Events::GetNextJobEvent => method(:handle_get_next_job),
        Events::ReportJobStateEvent => method(:handle_report_job_state)
      }
    end

    # Runs loop to handle events from queue
    def event_loop
      loop do
        event_promise = @queue.dequeue
        begin
          event = event_promise.value!
          logger.debug("took an event #{event} from event queue")
        rescue StandardError
          raise 'failed to dequeue event from event queue'
        end

        dispatch(event)
      end
    end

    # Dispatches event to appropriate handler
    def dispatch(event)
      logger.info("dispatching event #{event}")
      event_class = event.class
      raise "unknown event class #{event_class}" unless handlers.key?(event_class)
      handlers.fetch(event_class).call(event)
      logger.info("event #{event} dispatched")
    rescue StandardError => e
      logger.error "failed to dispatch #{event}"
      logger.error e
    end

    def schedule_report_status
      event = Events::ReportStatusEvent.new
      enqueue_task(event)
    end

    def schedule_get_next_job
      event = Events::GetNextJobEvent.new
      enqueue_task(event)
    end

    # Schedules reporting of job state
    # @param project_tag [Symbol]
    # @param job_tag [Symbol]
    # @param agent_tag [Symbol]
    # @param state [Nanoci::Build::State]
    def schedule_job_state_report(project_tag, job_tag, agent_tag, state)
      event = Events::ReportJobStateEvent.new(project_tag, job_tag, agent_tag, state)
      enqueue_task(event)
    end

    def handle_report_status(_event)
      logger.debug('reporting agent status...')
      tag = @agent.tag
      status = AgentStatus.key(@agent.status)
      capabilities = @agent.capabilities.keys
      @service_client.report_agent_status(tag, status, capabilities)
      logger.debug('successfully reported agent status')

      schedule_get_next_job if @agent.status == AgentStatus::IDLE
    end

    def handle_get_next_job(_event)
      logger.debug('requesting next job for the agent...')
      build_job = @service_client.get_next_job(@agent.tag)
      run_job(build_job) unless build_job.nil?
      logger.debug('successfully requested next job for the agent')
    end

    def run_job(build_job)
      @agent.run_job(build_job.build, build_job).then do |result|
        schedule_job_state_report(result)
      end
    end

    def handle_report_job_state(event)
      logger.debug("reporting job #{event.job_tag} state...")
      @service_client.report_job_state(event.result)
      logger.debug("successfully reported job #{event.job_tag} state")
    end
  end
end
