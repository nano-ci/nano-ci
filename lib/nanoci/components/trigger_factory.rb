# frozen_string_literal: true

require 'nanoci/triggers/interval_trigger'
require 'nanoci/not_implemented_error'

module Nanoci
  module Components
    # Creates new trigger from type and schedule
    # @param tag [Symbol]
    # @param type [Symbol]
    # @param schedule [String]
    class TriggerFactory
      def create(tag, type, schedule)
        case type
        when :interval
          Triggres::IntevalTrigger.new(tag, type, schedule)
        else
          raise NotImplementedError, "trigger type #{type} is not supported"
        end
      end
    end
  end
end