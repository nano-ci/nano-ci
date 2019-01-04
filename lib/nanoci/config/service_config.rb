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

      # job-scheduler-interval config name
      JOB_SCHEDULER_INTERVAL = :'job-scheduler-interval'

      # mongo-connection-string config name
      MONGO_CONNECTION_STRING = :'mongo-connection-string'

      # project config name
      PROJECT = :project

      # repo-cache config name
      REPO_CACHE = :'repo-cache'
    end
  end
end
