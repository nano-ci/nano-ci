# frozen_string_literal: true

# grpc generates code with a simple require
# add nanoci/remote directory to load path
# so grpc generated files are able to find each other
$LOAD_PATH.unshift __dir__

require 'logging'

require 'nanoci/build'
require 'nanoci/config/ucs'
require 'nanoci/definition/project_definition'
require 'nanoci/project'
require 'nanoci/remote/agent_manager_services_pb'
require 'nanoci/remote/get_next_job_message_pb'
require 'nanoci/remote/report_agent_status_message_pb'
require 'nanoci/remote/report_job_state_message_pb.rb'

module Nanoci
  module Remote
    # Agent manager service client
    class AgentManagerServiceClient
      include Logging.globally

      def initialize
        @service_uri = Config::UCS.instance.agent_manager_service_uri
        logger.info("reporting to agent manager service at #{@service_uri}")
        @client = AgentManager::Stub.new(@service_uri, :this_channel_is_insecure)
      end

      # Requests next job for an agent
      # @param tag [Symbol] agent tag
      # @return [Nanoci::BuildJob]
      def get_next_job(tag)
        request = GetNextJobRequest.new(
          tag: tag.to_s
        )
        response = @client.get_next_job(request)
        build_job = nil

        if response.has_job
          project_src = YAML.safe_load(response.project_definition, [Symbol])
                            .symbolize_keys
          project_definition = Definition::ProjectDefinition.new(project_src)
          project = Project.new(project_definition)
          variables = response.variables.to_hash.symbolize_keys
          commits = response.commits.to_hash.symbolize_keys
          build = Build.new(project, nil, variables)
          build.commits = commits
          stage_tag = response.stage_tag.to_sym
          job_tag = response.job_tag.to_sym
          build_job = build
                      .stages.select { |s| s.tag == stage_tag }.first
                      .jobs.select { |j| j.tag == job_tag }.first
        end

        build_job
      end

      # Reports agent status to nano-ci service
      # @param tag [Symbol] agent tag
      # @param status [Symbol] agent status
      # @param capabilities [Array<Symbol>] agent capabilities
      def report_agent_status(tag, status, capabilities)
        request = ReportAgentStatusRequest.new(
          tag: tag.to_s,
          status: status.to_s,
          capabilities: capabilities.map(&:to_s)
        )
        @client.report_agent_status(request)
      end

      # Reports job state
      # @param agent_tag [Symbol] agent tag
      # @param job_tag [Symbol] job tag
      # @param state [Nanoci::Build::State] job state
      def report_job_state(agent_tag, job_tag, state)
        request = ReportJobStateRequest.new(
          agent_tag: agent_tag.to_s,
          job_tag: job_tag.to_s,
          state: Build::State.key(state)
        )
        @client.report_job_state(request)
      end
    end
  end
end
