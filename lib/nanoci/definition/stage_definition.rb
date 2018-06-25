# frozen_string_literal: true

require 'nanoci/definition/job_definition'

class Nanoci
  class Definition
    class StageDefinition
      # Returns stage tag
      # @return [Symbol]
      attr_reader :tag

      # Returns array of jobs in the stage
      # @return [Array<JobDefinition>]
      attr_reader :jobs

      # Initializes new instance of the [StageDefinition]
      # @param hash [Hash]
      def initialize(hash)
        @tag = hash.fetch :tag
        @jobs = read_jobs(hash.fetch(:jobs, []))
      end

      # Reads array of jobs from src
      # @param job_hash_array [Array<Hash>]
      # @return [Array<JobDefinition>]
      def read_jobs(job_hash_array)
        job_hash_array.select(&:read_job)
      end

      # Reads job from src
      # @param hash [Hash]
      # @return [JobDefinition]
      def read_job(hash)
        JobDefinition.new(hash)
      end
    end
  end
end
