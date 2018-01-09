class Nanoci
  class Config
    def initialize(src)
      @src = src
    end

    def local_agents
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
        @src['capabilities'] || []
      end

      def agents

      end

      class LocalAgentConfig
        def initialize(src)
          @src = src
        end

        def name
          @src['name']
        end

        def capabilities
          @src['capabilites'] || []
        end
      end
    end
  end
end
