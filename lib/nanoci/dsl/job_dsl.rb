# frozen_string_literal: true

require 'nanoci/core/job'

module Nanoci
  module DSL
    # JobDSL class contains methods to support nano-ci DSL
    class JobDSL
      # Initializes new instance of [Nanoci::DSL::JobDSL]
      # @param component_factory [Object]
      # @param tag [Symbol]
      # @param work_dir [String]
      # @param env [Hash]
      # @param docker_image [String]
      def initialize(component_factory, tag, work_dir: '.', env: nil, docker_image: nil, &block)
        @component_factory = component_factory
        @tag = tag
        @work_dir = work_dir
        @env = env
        @docker_image = docker_image
        @block = block
      end

      def build
        Core::Job.new(
          tag: @tag,
          body: @block,
          work_dir: @work_dir,
          env: @env
        )
      end
    end
  end
end
