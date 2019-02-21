# frozen_string_literal: true

require 'nanoci/agent_status'
require 'nanoci/mixins/logger'
require 'nanoci/remote_agent'
require 'nanoci/remote/agent_manager_services_pb'
require 'nanoci/remote/get_next_job_message_pb'
require 'nanoci/remote/report_agent_status_message_pb'

module Nanoci
  module Remote
    # Implementation of RPC service AgentManager
    class AgentManagerServiceImpl < AgentManager::Service
      include Logging.globally

      # Gets an [AgentManager]
      # @return [Nanoci::AgentManager]
      attr_reader :agent_manager

      def initialize(agent_manager)
        @agent_manager = agent_manager
      end

      # Report remote agent status and capabilities
      # @param report_agent_status_request [ReportAgentStatusRequest]
      # @param _call [Object]
      # @return [Nanoci::Remote::ReportAgentStatusResponse]
      def report_agent_status(report_agent_status_request, _call)
        tag = report_agent_status_request.tag.to_sym
        status = report_agent_status_request.status
        capabilities = report_agent_status_request.capabilities.map { |x| [x.to_sym, true] }.to_h
        agent = get_agent(tag) || add_agent(tag, capabilities)
        agent.status = Nanoci::AgentStatus.value(status)
        agent.capabilities = capabilities
        ReportAgentStatusResponse.new
      end

      # Process a request from remote agent for a next job
      # @param request [Nanoci::Remote::GetNextJobRequest]
      # @param _call [Object]
      # @return [Nanoci::Remote::GetNextJobResponse]
      def get_next_job(request, _call)
        tag = request.tag.to_sym
        agent = get_agent(tag)
        raise "agent #{tag} not found" if agent.nil?
        (_fulfilled, job, reason) = agent.pending_job.result(60)
        raise reason unless reason.nil?
        if job.nil?
          response = GetNextJobResponse.new(
            has_job: false
          )
        else
          build = agent.build
          response = GetNextJobResponse.new(
            has_job: true,
            build_tag: build.tag,
            project_tag: build.project.tag,
            stage_tag: build.current_stage.tag,
            job_tag: job.tag,
            project_definition: build.project.definition.to_yaml,
            variables: build.variables.map { |k, v| [k.to_s, v.to_s]}.to_h,
            commits: build.commits.map { |k, v| [k.to_s, v.to_s]}.to_h
          )
        end
        response
      end

      # Reports job execution state from agent
      # @param request [Nanoci::Remote::ReportJobStateRequest]
      # @param _call [Object]
      # @return [Nanoci::Remote::ReportJobStateResponse]
      def report_job_state(request, _call)
        agent_tag = request.agent_tag.to_sym
        agent = agent_manager.get_agent(agent_tag)
        if agent.nil?
          logger.warning("received job status update from unknown agent #{agent_tag}, ignoring")
          return ReportJobStateResponse.new
        end

        job = agent.current_job

        if job.tag != request.job_tag.to_sym
          logger.warning("received invaid job status update from agent #{agent_tag} - agent is not working on job #{job_tag}")
          return ReportJobStateResponse.new
        end

        job.state = Nanoci::Build::State.value(request.state)

        ReportJobStateResponse.new
      end

      private

      # Gets an agent from agent manager.
      # It creates a new [Nanoci::RemoteAgent] if agent does not exist.
      # @param tag [Symbol]
      # @return [Nanoci::Agent]
      def get_agent(tag)
        agent_manager.get_agent(tag)
      end

      def add_agent(tag, capabilities)
        agent = RemoteAgent.new(tag, capabilities)
        agent_manager.add_agent(agent)
      end
    end
  end
end
