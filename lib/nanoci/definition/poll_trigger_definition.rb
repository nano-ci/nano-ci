# frozen_string_literal: true

require 'nanoci/definition/trigger_definition'

module Nanoci
  class Definition
    # Poll trigger definition
    class PollTriggerDefinition < TriggerDefinition
      attr_reader :interval

      # Initializes new instance of [PollTriggerDefinition]
      # @param hash [Hash]
      def initialize(hash)
        super(hash)

        @interval = hash.fetch(:interval)
      end
    end
  end
end
