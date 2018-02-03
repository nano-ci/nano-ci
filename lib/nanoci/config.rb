class Nanoci
  class Config
    def initialize(src)
      @src = src
    end

    def local_agents
      return nil if @src['local_agents'].nil?
      LocalAgentsConfig.new(@src['local_agents'])
    end

    def job_scheduler_interval
      @src['job_scheduler_interval'] || 5
    end

    def plugins_path
      @src['plugins-path']
    end

    def capabilities
      caps = (@src['capabilities'] || []).map do |x|
        case x
        when String then [x, nil]
        when Hash then x.entries[0]
        end
      end
      caps.to_h
    end

    def repo_cache
      @src['repo-cache']
    end

    def logdir
      @src['logdir']
    end

    def agents
      (@src['agents'] || []).map { |x| LocalAgentConfig.new(x) }
    end

    class LocalAgentConfig
      def initialize(src)
        @src = src
      end

      def name
        @src['name']
      end

      def capabilities
        caps = (@src['capabilities'] || []).map do |x|
          case x
          when String then [x, nil]
          when Hash then x.entries[0]
          end
        end
        caps.to_h
      end

      def workdir
        @src['workdir']
      end
    end
  end
end
