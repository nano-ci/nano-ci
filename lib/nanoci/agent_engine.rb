# frozen_string_literal: true

require 'concurrent'
require 'ostruct'

require 'nanoci/agent_status'
require 'nanoci/config/ucs'
require 'nanoci/events/agent_events'
require 'nanoci/local_agent'
require 'nanoci/remote/agent_manager_service_client'

module Nanoci
  # nano-ci Agent engine
  class AgentEngine
    include Logging.globally

    # Initializes new instance of [AgentEngine]
    # @param event_engine [Nanoci::EventEngine]
    def initialize(event_engine)
      # @type [Nanoci::Remote:;AgentManagerServiceClient]
      @service_client = Remote::AgentManagerServiceClient.new

      # @type [Nanoci::LocalAgent]
      @agent = LocalAgent.new

      @event_engine = event_engine
      @event_engine.register(
        Events::REPORT_STATUS => method(:handle_report_status),
        Events::GET_NEXT_JOB => method(:handle_get_next_job),
        Events::REPORT_JOB_STATE => method(:handle_report_job_state)
      )

      interval = Config::UCS.instance.report_status_interval

      # @type [Concurrent::TimerTask]
      @report_status_timer = Concurrent::TimerTask.new(execution_interval: interval, run_now: true) do
        schedule_report_status
        unless @agent.current_job.nil?
          build_job = @agent.current_job
          schedule_job_state_report(build_job.build.project.tag, build_job.tag, @agent.tag, build_job.state)
        end
      end
    end

    # Runs the [AgentEngine]
    # @return [Concurrent::Promises::Future]
    def run
      logger.info('AgentEngine is running')
      @report_status_timer.execute
      @event_engine.run.then do
        logger.info('AgentEngine is stopped')
      end
    end

    private

    def schedule_report_status
      @event_engine.enqueue_task(Event.new(Events::REPORT_STATUS))
    end

    def schedule_get_next_job
      @event_engine.enqueue_task(Event.new(Events::GET_NEXT_JOB))
    end

    # Schedules reporting of job state
    # @param project_tag [Symbol]
    # @param job_tag [Symbol]
    # @param agent_tag [Symbol]
    # @param state [Nanoci::Build::State]
    def schedule_job_state_report(project_tag, job_tag, agent_tag, state)
      data = OpenStruct.new(
        project_tag: project_tag,
        job_tag: job_tag,
        agent_tag: agent_tag,
        state: state
      )
      event = Event.new(Events::REPORT_JOB_STATE, data)
      @event_engine.enqueue_task(event)
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

    # Runs a job on the agent
    # @param build_job [Nanoci::BuildJob]
    def run_job(build_job)
      @agent.run_job(build_job.build, build_job).then do |_result|
        schedule_job_state_report(build_job.build.project.tag, build_job.tag, @agent.tag, build_job.state)
      end
    end

    def handle_report_job_state(event)
      logger.debug("reporting job #{event.job_tag} state...")
      @service_client.report_job_state(event.agent_tag, event.job_tag, event.state)
      logger.debug("successfully reported job #{event.job_tag} state")
    end
  end
end
