# frozen_string_literal: true

require 'nanoci/components/trigger_factory'

module Nanoci
  module Components
    # ComponentFactory is an entry point to get access to component factories
    class ComponentFactory
      def triggers
        TriggerFactory.new
      end
    end
  end
end
