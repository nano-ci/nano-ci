require 'logging'

class Nanoci
  class Agent
    attr_accessor :name
    attr_accessor :current_job
    attr_accessor :workdir
    attr_reader   :repo_cache

    def initialize(config, capabilities)
      @log = Logging.logger[self]
      @name = config.name
      @repo_cache = config.repo_cache

      raise 'capabilities should be a Hash' unless capabilities.is_a? Hash
      @capabilities = config.capabilities.merge(capabilities)
      @workdir = config.workdir
      @current_job = nil
    end

    def run_job(job)
      @log.info "running job #{job.tag} on #{name}"
      self.current_job = job
    end

    def capability(name)
      @capabilities.key?(name) ? @capabilities[name] || true : nil
    end

    def capability?(required_capability)
      @capabilities.key?(required_capability)
    end

    def capabilities?(required_capabilities)
      raise 'required_capabilities should be a Set' unless required_capabilities.is_a? Set
      Set.new(@capabilities.keys.to_set).superset? required_capabilities
    end
  end
end
