# frozen_string_literal: true

require 'logging'

module Nanoci
  # Agent is an instance of nano-ci service that executes commands from
  # a main nano-ci service to run build jobs
  class Agent
    attr_accessor :tag

    # Agent capabilities
    # @return [Hash<Symbol, String>]
    attr_reader :capabilities

    attr_reader :status
    attr_reader :status_timestamp
    attr_accessor :current_job
    attr_accessor :workdir

    def initialize(tag, capabilities)
      @log = Logging.logger[self]
      @tag = tag

      raise 'capabilities should be a Hash' unless pabilities.is_a? Hash
      @capabilities = capabilities
      @current_job = nil
    end

    def status=(value)
      @status = value
      @status_timestamp = Time.now.utc
    end

    def capability(name)
      @capabilities.key?(name) ? @capabilities[name] || true : nil
    end

    def capability?(required_capability)
      @capabilities.key?(required_capability)
    end

    def capabilities?(required_capabilities)
      raise 'required_capabilities should be a Set' \
        unless required_capabilities.is_a? Set
      Set.new(@capabilities.keys.to_set).superset? required_capabilities
    end

    def run_job(_build, job)
      @log.info "running job #{job.tag} on #{tag}"
      self.current_job = job
    end
  end
end
