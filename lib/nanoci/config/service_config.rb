# frozen_string_literal: true

module Nanoci
  module Config
    # UCS config module to access nano-ci service variables
    module ServiceConfig
      # Job scheduler execution interval in seconds
      # @return [Number]
      def job_scheduler_interval
        get(ServiceConfig::JOB_SCHEDULER_INTERVAL, 5)
      end

      # MongoDB connection string
      # @return [String]
      def mongo_connection_string
        get(ServiceConfig::MONGO_CONNECTION_STRING)
      end

      # path to project definition file
      # @return [String]
      def project
        get(ServiceConfig::PROJECT)
      end

      # path to repo cache directory
      # @return [String]
      def repo_cache
        get(ServiceConfig::REPO_CACHE)
      end

      def agent_service_host_address
        get(ServiceConfig::AGENT_SERVICE_HOST_ADDRESS)
      end

      def pending_job_timeout
        get(ServiceConfig::PENDING_JOB_TIMEOUT).to_i
      end

      # job-scheduler-interval config name
      JOB_SCHEDULER_INTERVAL = :'job-scheduler-interval'

      # mongo-connection-string config name
      MONGO_CONNECTION_STRING = :'mongo-connection-string'

      # project config name
      PROJECT = :project

      # repo-cache config name
      REPO_CACHE = :'repo-cache'

      # agent-service-host-address config name
      AGENT_SERVICE_HOST_ADDRESS = :'agent-service-host-address'

      PENDING_JOB_TIMEOUT = :'pending-job-timeout'
    end
  end
end
