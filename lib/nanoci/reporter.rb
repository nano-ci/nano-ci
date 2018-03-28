require 'nanoci/not_implemented_error'

class Nanoci
  class Reporter
    module What
      ALL = :all
      FAIL = :fail

      ALL_VALUES = [ALL, FAIL].freeze
    end

    @types = {}

    def self.types
      @types
    end

    def self.create(type, config, src)
      reporter_class = types[type]
      if reporter_class.nil?
        raise "Unknown reporter type #{type}"
      end
      reporter_class.new(config, src)
    end

    def what
      @what
    end

    def initialize(_config, src = {})
      @what = src.fetch('what', 'fail').to_sym
      raise "invalid 'what' value - #{@what}" unless What::ALL_VALUES.include?(@what)
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
