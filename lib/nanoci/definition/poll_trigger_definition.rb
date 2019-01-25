# frozen_string_literal: true

require 'nanoci/definition/trigger_definition'

module Nanoci
  class Definition
    # Poll trigger definition
    class PollTriggerDefinition < TriggerDefinition
      def interval
        @hash.fetch(:interval)
      end
    end
  end
end
