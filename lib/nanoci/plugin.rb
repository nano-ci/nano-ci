# frozen_string_literal: true

class Nanoci
  ##
  # Base class for nano-ci plugins
  class Plugin
    class << self
      def plugins
        @plugins ||= []
      end
    end
  end
end
