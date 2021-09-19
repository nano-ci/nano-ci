require 'nanoci/not_implemented_error'

module Nanoci
  class Reporter
    module What
      ALL = :all
      FAIL = :fail

      ALL_VALUES = [ALL, FAIL].freeze
    end

    class << self
      def types
        @types ||= {}
      end
    end

    attr_reader :what

    def self.create(type, src)
      reporter_class = types[type]
      raise "Unknown reporter type #{type}" if reporter_class.nil?

      reporter_class.new(src)
    end

    def initialize(src = {})
      @what = src.fetch(:what, 'fail').to_sym
      raise "invalid 'what' value - #{what}" unless What::ALL_VALUES.include?(what)
    end

    def report(build)
      case what
      when What::ALL
        send_report(build)
      when What::FAIL
        send_report(build) if build.state == Build::State::FAILED
      end
    end

    def send_report(_build)
      raise NotImplementedError(self.class.name, __method__.to_s)
    end
  end
end
