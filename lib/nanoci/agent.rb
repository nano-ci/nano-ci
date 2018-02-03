require 'logging'

class Nanoci
  class Agent
    attr_accessor :name
    attr_accessor :current_job
    attr_accessor :workdir

    def initialize(config, capabilities, env)
      @log = Logging.logger[self]
      @name = config.name

      raise 'capabilities should be a Hash' unless capabilities.is_a? Hash
      @capabilities = config.capabilities.merge(capabilities)
      @workdir = config.workdir
      @env = env
      @current_job = nil
    end

    def run_job(build, job)
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

    def execute_task(build, task)
      env = @env.merge(@capabilities)
      env['workdir'] = @workdir
      task.execute(build, env)
    end
  end
end
