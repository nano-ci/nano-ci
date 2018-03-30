# frozen_string_literal: true

require 'logging'

class Nanoci
  class Mixins
    ##
    # Mixin class that enables logging for a class
    module Logger
      def log
        Logging.logger[self]
      end
    end
  end
end
