require 'logging'

class Nanoci
  class Agent
    attr_accessor :name
    attr_accessor :capabilities
    attr_accessor :current_job

    def initialize(config, capabilities)
      @log = Logging.logger[self]
      @name = config.name
      @capabilities = config.capabilities + capabilities
      @current_job = nil
    end

    def run_job(job)
      @log.info "running job #{job.definition.tag} on #{name}"
      self.current_job = job
    end
  end
end
