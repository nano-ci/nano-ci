# frozen_string_literal: true

require 'intake'

module Nanoci
  class Mixins
    # Mixin class that enables logging for a class
    module Logger
      def log
        Intake[self]
      end
    end
  end
end
