# frozen_string_literal: true

module Nanoci
  module Config
    # UCS config module to access nano-ci service variables
    module ServiceConfig
      # @return job scheduler executin interval in seconds
      def job_scheduler_interval
        get(ServiceConfig::JOB_SCHEDULER_INTERVAL)
      end

      # @return MongoDB connection string
      def mongo_connection_string
        get(ServiceConfig::MONGO_CONNECTION_STRING)
      end

      # @return path to project definition file
      def project
        get(ServiceConfig::Project)
      end

      # job-scheduler-interval config name
      JOB_SCHEDULER_INTERVAL = :'job-scheduler-interval'

      # mongo-connection-string config name
      MONGO_CONNECTION_STRING = :'mongo-connection-string'

      # project config name
      PROJECT = :project
    end
  end
end
