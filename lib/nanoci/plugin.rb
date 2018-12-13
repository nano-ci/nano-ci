# frozen_string_literal: true

module Nanoci
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
