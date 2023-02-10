# frozen_string_literal: true

require 'ruby-enum'

module Nanoci
  module Core
    # Enum listing valid values for downstream_valid_value DSL key
    class DownstreamTriggerRule
      include Ruby::Enum

      define :queue
      define :ignore_if_running
    end
  end
end
