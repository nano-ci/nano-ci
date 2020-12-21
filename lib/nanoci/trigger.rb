# frozen_string_literal: true

require 'logging'

require 'nanoci/mixins/provides'

module Nanoci
  ##
  # Base class for nano-ci triggers
  class Trigger
    extend Mixins::Provides

    def self.item_type
      'trigger'
    end

    # @return [Symbol]
    attr_reader :tag

    # @return [Symbol]
    attr_reader :type

    # Initializes new instance of [Trigger]
    # @param definition [Hash]
    def initialize(hash)
      @log = Logging.logger[self]
      @tag = hash[:tag]
      @type = hash[:type]
    end

    # Starts the trigger
    # @param pipeline_engine [#push_input]
    # @param project [Nanoci::Project]
    def run(pipeline_engine, project)
      @pipeline_engine = pipeline_engine
      @project = project

      @log.info("running trigger #{tag}")
    end

    protected

    # Formats output tag by adding trigger prefix
    # @param output_tag [Symbol]
    # @return [Symbol]
    def format_output(output_tag)
      "trigger.#{tag}.#{output_tag}".to_sym
    end
  end
end
