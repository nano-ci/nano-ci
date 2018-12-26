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

    def job_scheduler_interval
      @src['job_scheduler_interval'] || 5
    end

    def mongo_connection_string
      @src['mongo-connection-string']
    end

    def email
      EmailConfig.new(@src['email'] || {})
    end

    # Email config class
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
