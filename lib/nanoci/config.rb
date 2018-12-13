# frozen_string_literal: true

module Nanoci
  ##
  # nano-ci config which is read from config file
  class Config
    def self.env(name)
      return name unless name.is_a? String
      match = /\$\{([^}]*)\}/.match(name)
      if match.nil? || ENV[match[1]].nil?
        name
      else
        ENV[match[1]]
      end
    end

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
      caps.map { |x| [x[0].to_sym, x[1]] }.to_h
    end

    def repo_cache
      @src['repo-cache']
    end

    def build_data_dir
      @src['build-data-dir']
    end

    def agents
      (@src['agents'] || []).map { |x| LocalAgentConfig.new(x) }
    end

    def mongo_connection_string
      @src['mongo-connection-string']
    end

    def email
      EmailConfig.new(@src['email'] || {})
    end

    ##
    # Local agent config
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

    class EmailConfig
      def initialize(src)
        @src = src
      end

      def from
        Config.env(@src['from'])
      end

      def host
        Config.env(@src['host'])
      end

      def port
        Config.env(@src['port'])
      end

      def encryption
        Config.env(@src['encryption'])&.to_s || :none
      end

      def username
        Config.env(@src['username'])
      end

      def password
        Config.env(@src['password'])
      end
    end
  end
end
