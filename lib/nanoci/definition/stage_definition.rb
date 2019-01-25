# frozen_string_literal: true

require 'nanoci/definition/job_definition'

module Nanoci
  class Definition
    class StageDefinition
      # Returns stage tag
      # @return [Symbol]
      def tag
        @hash.fetch(:tag)
      end

      # Returns array of jobs in the stage
      # @return [Array<JobDefinition>]
      def jobs
        read_jobs(@hash.fetch(:jobs, []))
      end

      # Initializes new instance of the [StageDefinition]
      # @param hash [Hash]
      def initialize(hash)
        @hash = hash
      end

      private

      # Reads array of jobs from src
      # @param job_hash_array [Array<Hash>]
      # @return [Array<JobDefinition>]
      def read_jobs(job_hash_array)
        job_hash_array.map { |d| JobDefinition.new(d) }
      end
    end
  end
end
