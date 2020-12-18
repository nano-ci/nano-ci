# frozen_string_literal: true

module Nanoci
  module DSL
    # StageDSL class contains methods to support nano-ci stage DSL.
    class StageDSL
      def initialize(tag, params = {})
        @tag = tag
        @inputs = params.fetch(:inputs, [])
        @jobs = []
      end

      def job(tag, params = {}, &block)
        raise "job #{tag} is missing definition block" if block.nil?
        job = JobDSL.new(tag, params, block)
        @jobs.push(job)
      end

      def build
        {
          tag: @tag,
          inputs: @inputs,
          jobs: @jobs.collect(&:build)
        }
      end
    end
  end
end
