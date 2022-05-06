# frozen_string_literal: true

require 'nanoci/not_implemented_error'

module Nanoci
  module Core
    # Creates new trigger from type and schedule
    # @param type [Symbol]
    # @param schedule [String]
    class TriggerFactory
      def create(type, schedule)
        raise NotImplementedError
      end
    end
  end
end
