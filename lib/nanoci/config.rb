# frozen_string_literal: true

module Nanoci
  # nano-ci config which is read from config file
  module Config
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
