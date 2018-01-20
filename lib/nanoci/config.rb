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
      @src['plugins_path']
    end

    class LocalAgentsConfig
      def initialize(src)
        @src = src
      end

      def capabilities
        Set.new (@src['capabilities'] || []).map do |x|
          case x
          when String then AgentCapability.new(x, nil)
          when Hash then AgentCapability.new(x.entries[0][0], x.entries[0][1])
          end
        end
      end

      def agents
        (@src['agents'] || []).map { |x| LocalAgentConfig.new(x) }
      end
    end

    class LocalAgentConfig
      def initialize(src)
        @src = src
      end

      def name
        @src['name']
      end

      def capabilities
        Set.new (@src['capabilities'] || []).map do |x|
          case x
          when String then AgentCapability.new(x, nil)
          when Hash then AgentCapability.new(x.entries[0][0], x.entries[0][1])
          end
        end
      end
    end
  end
end
