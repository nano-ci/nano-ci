# frozen_string_literal: true

require 'nanoci/agent'

module Nanoci
  # Remote agent
  class RemoteAgent < Agent
    # Sets a capabilities to a set reported by remote agent
    # @param value [Hash<Symbol>]
    def capabilities=(value)
      raise 'value should be a hash' unless value.is_a? Hash
      @capabilities = value
    end
  end
end
